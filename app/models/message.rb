class Message
  include Neo4j::ActiveNode
  property :text, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :in, :chat, origin: :messages
  has_one :in, :user, origin: :messages

  validates :text, presence: true

  def user_location_name
    if user
      move = chat.moves.find_by(user: user)
     if move
        move.from_group.location.name
     else
        I18n.t('message_of_deleted_move')
     end
    else
      I18n.t('system_message')
    end
  end
end
