require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test 'should not save without name' do
    location = build :location
    location.name = ''
    assert_not location.valid?
  end

  test 'should not save without city' do
    location = build :location
    location.city = nil
    assert_not location.valid?
  end

  test 'on destroy should destroy groups that belongs to location' do
    location = create :location
    create :group, location: location
    create :group, location: location
    assert_difference "Location.count", -1 do
      assert_difference "Group.count", -2 do
        location.destroy
      end
    end
  end
end
