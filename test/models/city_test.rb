require 'test_helper'

class CityTest < ActiveSupport::TestCase
  test "destroy will destroy locations that belongs to city" do
    city = create :city
    create :location, city: city
    assert_difference "Location.count", -1 do
      city.destroy
    end
  end
end
