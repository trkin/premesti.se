class City
  include Neo4j::ActiveNode
  property :name, type: String

  has_many :in, :locations, origin: :city, dependent: :destroy

  validates :name, presence: true
end
