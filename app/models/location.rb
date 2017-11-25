class Location
  include Neo4j::ActiveNode
  property :name, type: String
  property :address, type: String
  property :latitude, type: Float
  property :longitude, type: Float

  has_many :out, :groups, type: :HAS_GROUPS

  validates :name, presence: true
end
