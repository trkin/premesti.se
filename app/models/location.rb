class Location
  include Neo4j::ActiveNode
  property :name, type: String
  property :address, type: String
  property :latitude, type: Float
  property :longitude, type: Float

  validates :name, presence: true
end
