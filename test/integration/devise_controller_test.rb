require 'test_helper'

class DeviseControllerTest < ActionDispatch::IntegrationTest
  test 'registration' do
    email = 'my@email.com'
    password = '12345678'
    assert_difference 'User.count', 1 do
      assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
        post user_registration_path, params: { user: { email: email, password: password, password_confirmation: password, locale: I18n.default_locale } }
      end
    end
    follow_redirect!
    assert_select '#notice-debug', t('devise.registrations.signed_up')
    assert_select '#userDropdown', text: 'my'
    registration_mail = give_me_last_mail_and_clear_mails
    assert_match t('my_devise_mailer.please_follow_the_link_below_in_order_to_confirm_your_email'), registration_mail.html_part.decoded
  end
end
