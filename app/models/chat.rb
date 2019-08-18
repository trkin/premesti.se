class Chat
  include Neo4j::ActiveNode
  ARCHIVED_REASONS = %i[
    this_chat_completed_successfully
    other_participants_do_not_reply
  ].freeze

  property :name, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime
  property :status, type: Integer, default: 0
  property :archived_reason, type: String

  enum status: %i[active archived]

  has_many :out, :messages, type: :HAS_MESSAGES
  has_many :out, :moves, rel_class: :Matches

  def ordered_moves
    return @ordered_moves if @ordered_moves.present?

    @ordered_moves = query_as(:c).match('(c)-[r:MATCHES]-(m:Move)').order('r.order').pluck(:m)
  end

  def name_with_arrows(email_and_phone: false)
    return I18n.t('all_moves_are_deleted') unless moves.present?

    return @name_with_arrows if @name_with_arrows.present?

    @name_with_arrows = ([ordered_moves.last] + ordered_moves).map do |m|
      m.from_group.location.name + \
        (email_and_phone && m.user.email_with_phone_if_present ? "(#{m.user.email_with_phone_if_present})" : '')
    end.join(" #{Constant::ARROW_CHAR} ")
  end

  def name_for_user(_user)
    name_with_arrows email_and_phone: true
  end

  def from_location_for_user(user)
    move = moves.find_by user: user
    move.from_group.location
  end

  def archive_all_for_user_and_reason(user, archived_reason)
    if Move::ARCHIVED_REASONS.include? archived_reason.to_sym
      # delete to_group in move which will delete all chats
      move = moves.find_by(user: user)
      from_locations = moves.from_group.location
      target_group = move.to_groups.select { |to_group| from_locations.include? to_group.location }.first
      move.destroy_to_group_and_archive_chats(target_group, archived_reason)
    else
      archive_for_location_and_reason from_location_for_user(user), archived_reason
    end
  end

  def archive_for_location_and_reason(location, archived_reason)
    self.archived_reason = archived_reason
    archived!
    save!
    Message.create! chat: self, text: I18n.t('user_archived_chat_with_message', location: location.name, message: I18n.t(archived_reason))
  end

  # you can call Chat.create_for_moves [m1, m2] or without square brackets
  # Chat.create_for_moves m1, m2
  def self.create_for_moves(*moves)
    moves = moves.flatten
    raise 'can_not_create_for_less_than_two_moves' if moves.length < 2

    chat = Chat.create
    # we need to add property on relationship so we know which is next jump
    moves.each_with_index do |move, i|
      # chat.moves << move
      Matches.create from_node: chat, to_node: move, order: i
    end
    Message.create! chat: chat, text: I18n.t('new_match_for_moves', moves: chat.name_with_arrows(email_and_phone: true))
    moves.each do |move|
      next unless move.user.initial_chat_message.present?

      Message.create!(chat: chat, text: move.user.initial_chat_message, user: move.user)
    end
    chat
  end

  def self.find_existing_for_moves(moves)
    move_ids = moves.map(&:id)
    query = '(c)'
    where_different = 'true'
    where_include = 'true'
    moves.size.times do |i|
      query << ",(c)-[:MATCHES]-(m#{i}:Move)"
      i.times do |j|
        where_different << " AND m#{i} <> m#{j} "
      end
      where_include << " AND m#{i}.uuid IN ?"
    end
    Chat.active
        .query_as(:c)
        .match(query)
        .where(where_different)
        .where(where_include, move_ids)
        .pluck(:c)
        .uniq
  end
end
