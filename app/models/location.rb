class Location
  include Neo4j::ActiveNode
  include TranslatedProperty
  translate_property :name, type: String
  translate_property :address, type: String
  property :latitude, type: Float
  property :longitude, type: Float
  property :updated_at, type: DateTime

  has_many :out, :groups, type: :HAS_GROUPS, dependent: :destroy
  has_one :out, :city, type: :IN_CITY

  validates :name, :city, :address, :latitude, :longitude, presence: true

  attr_accessor :group_ages
  attr_accessor :description_for_map, :url_for_map

  def create_groups(ages)
    ages.each do |age|
      next unless age.positive?

      Group.create location: self, age: age
    end
  end

  def description
    "#{address} #{groups.map(&:name).join(',')}"
  end

  def name_with_address
    "#{name}, #{address}"
  end
end
