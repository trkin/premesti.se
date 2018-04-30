require 'test_helper'

class DeviseControllerTest < ActionDispatch::IntegrationTest
  test 'email signup' do
    email = 'my@email.com'
    password = '12345678'
    assert_difference "User.count", 1 do
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        post user_registration_path, params: { user: { email: email, password: password, password_confirmation: password } }
        follow_redirect!
        assert_select '#notice-debug', t("devise.registrations.signed_up")
        assert_select 'span', text: email
      end
    end
    ActionMailer::Base.deliveries.clear
  end
end
