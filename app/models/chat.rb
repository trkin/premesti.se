class Chat
  include Neo4j::ActiveNode
  ARCHIVED_REASONS = %i[
    other_participants_do_not_reply
    this_chat_completed_successfully
  ].freeze

  property :name, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime
  property :status, type: Integer, default: 0
  property :archived_reason, type: String

  enum status: %i[active archived]

  has_many :out, :messages, type: :HAS_MESSAGES
  has_many :out, :moves, type: :MATCHES, model_class: :Move, unique: true

  def name_with_arrows(moves)
    # in match result we got array of moves
    ([moves.last] + moves).reverse.map { |m| m.from_group.location.name }.join(" #{Constant::ARROW_CHAR} ")
  end

  def name_for_user(user)
    move = moves.find_by user: user
    if move.nil?
      if user.admin?
        moves.from_group.location.map(&:name).join ' '
      else
        Notify.message 'can_not_find_user_for_chat', chat_url(self), user.email
      end
    else
      # we create chat for moves (and multiple to_groups) so to find exact to_group we need this
      to_location = move.to_groups.location.find_by id: moves.from_group.location.map(&:uuid)
      if to_location
        to_group = move.to_groups.where(location: to_location).first
        my_loc_string = move.group_age_and_particular_group_location(to_group)
      else
        my_loc_string = move.group_age_and_locations
      end
      # find to_group for each other move
      location_ids = moves.from_group.location.map &:uuid
      other_loc_string = (moves.to_a - [move]).map do |other_move|
        to_location_other_move = other_move.to_groups.location.find_by id: location_ids
        if to_location_other_move
          other_move.from_group.location.name + '↪ ' + to_location_other_move.name
        else
          other_move.from_group.location.name + '↪  obrisan'
        end
      end.join('|')
      my_loc_string + '|' + other_loc_string
    end
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

  def self.create_for_moves(moves)
    chat = Chat.create
    moves.each do |move|
      chat.moves << move
    end
    Message.create! chat: chat, text: I18n.t('new_match_for_moves', moves: chat.name_with_arrows(moves))
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
