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

  attr_accessor :group_ages

  def create_groups(ages)
    ages.each do |age|
      next unless age > 0
      Group.create location: self, age: age
    end
  end

  def description
    "#{address} #{groups.map(&:name).join(',')}"
  end
end
