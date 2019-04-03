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

  def self.last_tag
    query_as(:e).order('e.created_at DESC').where('e.tag IS NOT NULL AND e.tag <> ""').limit(1).pluck(:e).first.tag
  end
end
