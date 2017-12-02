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
end
