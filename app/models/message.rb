class Message
  include Neo4j::ActiveNode
  property :text, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :in, :chat, origin: :messages
  has_one :in, :user, origin: :messages

  validates :text, presence: true

  def user_location
    chat.moves.find_by(user: user).from_group.location
  end
end
