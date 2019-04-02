class EmailMessage
  include Neo4j::ActiveNode

  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  property :to, type: String
  property :subject, type: String
  property :body, type: String
  property :text, type: String

  property :tag, type: String

  has_one :in, :user, origin: :email_messages
end
