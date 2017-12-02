class City
  include Neo4j::ActiveNode
  property :name, type: String

  has_many :in, :locations, origin: :city

  validates :name, presence: true
end
