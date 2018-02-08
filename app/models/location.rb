class Location
  include Neo4j::ActiveNode
  include TranslatedProperty
  translate_property :name, type: String
  translate_property :address, type: String
  property :latitude, type: Float
  property :longitude, type: Float

  has_many :out, :groups, type: :HAS_GROUPS
  has_one :out, :city, type: :IN_CITY

  validates :name, :city, :address, presence: true
end
