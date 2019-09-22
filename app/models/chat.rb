class Chat
  include Neo4j::ActiveNode
  property :name, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime
  property :status, type: Integer, default: 0
  property :archived_reason, type: String

  enum status: %i[active archived]

  has_many :out, :messages, type: :HAS_MESSAGES
  has_many :out, :moves, rel_class: :Matches
  has_many :out, :groups, rel_class: :MatchedGroups

  def ordered_moves
    return @ordered_moves if @ordered_moves.present?

    @ordered_moves = query_as(:c).match('(c)-[r:MATCHES]-(m:Move)').order('r.order').pluck(:m)
  end

  def ordered_groups
    return @ordered_groups if @ordered_groups.present?

    @ordered_groups = if groups.present?
                        query_as(:c).match('(c)-[r:MATCHED_GROUPS]-(m:Group)').order('r.order').pluck(:m)
                      else
                        query_as(:c).match('(c)-[r:MATCHES]-(m:Move)').order('r.order').pluck(:m).map(&:from_group)
                      end
  end

  def name_with_arrows(email_and_phone: false, skip_badges: false)
    return I18n.t('all_moves_are_deleted') unless moves.present?

    return @name_with_arrows if @name_with_arrows.present?

    array = ([ordered_moves.last] + ordered_moves).map do |m|
      m.from_group.location.name.html_safe + \
        (email_and_phone ? m.user.email_with_phone_if_present(skip_badges: skip_badges) : '')
    end
    # even result is SafeJoin we need to use .html_safe for
    # I18n.('name', name: chat.name_with_arrows).html_safe
    @name_with_arrows = ActionController::Base.helpers.safe_join(array, " #{Constant::ARROW_CHAR} ")
  end

  def name_for_user(_user)
    name_with_arrows email_and_phone: true
  end

  def from_location_for_user(user)
    move = moves.find_by user: user
    move.from_group.location
  end

  def archive_all_for_user_and_reason(user, archived_reason, admin: false)
    # delete to_group in move which will delete all chats
    move = moves.find_by(user: user)
    from_locations = ordered_groups.location
    target_group = move.to_groups.select { |to_group| from_locations.include? to_group.location }.first
    raise if target_group.nil?

    move.destroy_to_group_and_archive_chats(target_group, archived_reason, admin: admin)
  end

  def archive_for_move_and_reason(move, archived_reason, admin: false)
    moves.delete move
    self.archived_reason = archived_reason
    archived!
    save!
    message = if admin
                'admin_archived_chat_for_location_name_with_message'
              else
                'user_from_location_name_archived_with_message'
              end
    message_params = {
      chat: self,
      text: I18n.t(
        message,
        location_name: move.from_group.location.name, message: I18n.t(archived_reason)
      ),
    }
    message_decorator = MessageDecorator.new Message.new message_params
    message_decorator.save!
    message_decorator.save_and_send_notifications
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
      MatchedGroups.create from_node: chat, to_node: move.from_group, order: i
    end
    Message.create! chat: chat, text: I18n.t('new_match_for_moves', moves: chat.name_with_arrows(email_and_phone: true, skip_badges: true)).html_safe
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
