class Group
  include Neo4j::ActiveNode
  property :name, type: String
  property :age_min, type: Integer
  property :age_max, type: Integer
  has_one :in, :location, origin: :groups
  has_many :in, :move, origin: :group
end
