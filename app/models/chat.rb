class Chat
  include Neo4j::ActiveNode

  property :name, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_many :out, :messages, type: :HAS_MESSAGES
  has_many :out, :moves, type: :MATCHES, model_class: :Move, unique: true

  def name_for_user(user)
    move = moves.find_by user: user
    # this is not supported so we need to add references in chat for particular
    # group for which it was created
    # group = move.to_groups.find_by location: moves.map { |move| move.from_group.location }
    move.group_age_and_locations
  end

  def self.create_for_moves(moves)
    chat = Chat.create
    moves.each do |move|
      chat.moves << move
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
    Chat.query_as(:c)
        .match(query)
        .where(where_different)
        .where(where_include, move_ids)
        .pluck(:c)
  end
end
