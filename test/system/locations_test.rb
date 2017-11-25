require "application_system_test_case"

class LocationsTest < ApplicationSystemTestCase
  test "visiting the root" do
    create :location, name: 'my_location'
    visit root_url

    assert_text "What is your move?"
    assert_text 'my_location'
  end
end
