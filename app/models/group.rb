class Group
  include Neo4j::ActiveNode
  property :name, type: String
  property :birth_date_min, type: Date
  property :birth_date_max, type: Date
  property :age, type: Integer
  has_one :in, :location, origin: :groups
  has_many :in, :move, origin: :group

  validates :name, :location, presence: true
end
