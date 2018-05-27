require 'test_helper'

class DeviseControllerTest < ActionDispatch::IntegrationTest
  test 'email signup' do
    email = 'my@email.com'
    password = '12345678'
    assert_difference 'User.count', 1 do
      assert_difference 'all_mails.count', 1 do
        post user_registration_path, params: { user: { email: email, password: password, password_confirmation: password } }
      end
    end
    follow_redirect!
    assert_select '#notice-debug', t('devise.registrations.signed_up')
    assert_select '#userDropdown', text: 'my'
    registration_mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), registration_mail.html_part.decoded

  end
end
