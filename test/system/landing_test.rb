require "application_system_test_case"

class LandingTest < ApplicationSystemTestCase
  test 'create user and relationships' do
    group = create :group
    prefered_location = create :location, city: group.location.city
    prefered_group = create :group, location: prefered_location
    email = 'my@email.com'

    visit root_url
    within '#signup-form' do
      select group.location.city.name, from: t('landing_signup.current_city')
      select group.location.name, from: t('landing_signup.current_location')
      select group.name, from: t('landing_signup.from_group')
      select prefered_location.name, from: t('landing_signup.prefered_location')
      fill_in t('landing_signup.email'), with: email
      fill_in t('landing_signup.password'), with: '1234567'
      click_on t('landing_signup.submit')
    end

    user = User.find_by email: email
    assert_kind_of User, user
    move = user.moves.last
    assert_equal group, move.from_group
    assert_equal [prefered_group], move.prefered_groups
  end
end
