require "application_system_test_case"

class LandingTest < ApplicationSystemTestCase
  test 'create user and move with starting relationship' do
    location1 = create :location
    group1 = create :group, location: location1

    visit root_url
    within '#signup-form' do
      select location1.name, from: :current_location
      select group1.name, from: :current_group
    end
  end
end
