class Message
  include Neo4j::ActiveNode
  property :text, type: String
  property :reported_at, type: DateTime
  property :reported_by_user_id, type: String
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :in, :chat, origin: :messages
  has_one :in, :user, origin: :messages

  validates :text, presence: true

  scope :reported, -> { query_as('message').where('message.reported_at IS NOT NULL').pluck('*') }

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

  def report_by(user)
    self.reported_at = Time.zone.now
    self.reported_by_user_id = user.id
    save!
  end

  def cancel_report
    self.reported_at = nil
    self.reported_by_user_id = nil
    save!
  end
end
