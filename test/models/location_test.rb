require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test 'should not save without name' do
    location = Location.new
    assert_not location.save
  end
end
