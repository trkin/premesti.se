require "application_system_test_case"

class LandingTest < ApplicationSystemTestCase
  test 'create user and move with starting relationship' do
    visit root_url
    whithin '#signup' do
      fill_in ''
    end
  end
end
