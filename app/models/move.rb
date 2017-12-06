class Move
  include Neo4j::ActiveNode
  property :birth_date, type: Date
  property :name, type: String
  property :available_from_date, type: Date
  property :available_to_date, type: Date
  property :created_at, type: DateTime
  property :updated_at, type: DateTime

  has_one :in, :from_group, type: :CURRENT, model_class: :Group, unique: true
  has_many :out, :prefered_groups, type: :PREFER, model_class: :Group
  # property :priority, is on relationship, and not so important for now
  has_one :in, :user, origin: :moves

  validates :from_group, :user, presence: true
end
