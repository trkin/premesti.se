require "application_system_test_case"

class LocationsTest < ApplicationSystemTestCase
  test "visiting the root" do
    create :location, name: 'first_location'
    visit root_url

    assert_text "What is your move?"
    assert_text 'first_location'
  end
end
