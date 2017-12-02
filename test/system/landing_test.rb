require "application_system_test_case"

class LandingTest < ApplicationSystemTestCase
  test 'create user and relationships' do
    group = create :group

    visit root_url
    within '#signup-form' do
      select group.location.city.name, from: I18n.t('landing_signup.current_city')
      select group.location.name, from: I18n.t('landing_signup.current_location')
      select group.name, from: I18n.t('landing_signup.current_group')
    end
  end
end
