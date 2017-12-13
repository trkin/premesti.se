require 'test_helper'

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  def setup
    OmniAuth.config.test_mode = true
  end

  def teardown
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.mock_auth[:facebook] = nil
    OmniAuth.config.test_mode = false
  end

  test 'facebook login' do
    facebook_uid = '1234567890'
    user = create :user, facebook_uid: facebook_uid
    OmniAuth.config.add_mock :facebook, uid: facebook_uid

    get dashboard_path
    assert_response :redirect
    get user_facebook_omniauth_authorize_path
    follow_redirect!
    follow_redirect!
    assert_select 'span', user.email
    assert_select 'h1', 'dashboard'
  end

  test 'google login' do
    google_uid = '1234567890'
    user = create :user, google_uid: google_uid
    OmniAuth.config.add_mock :google_oauth2, uid: google_uid

    get user_google_oauth2_omniauth_authorize_path
    follow_redirect!
    follow_redirect!
    assert_select 'span', user.email
    assert_select 'div', t("devise.omniauth_callbacks.success", kind: t("provider.google_oauth2"))
  end

  test 'facebook signup' do
    email = 'my@email.com'
    OmniAuth.config.add_mock :facebook, info: { email: email }
    assert_difference "User.count", 1 do
      assert_difference "ActionMailer::Base.deliveries.size", 0 do
        get user_facebook_omniauth_authorize_path
        follow_redirect!
        follow_redirect!
        assert_select 'span', email
      end
    end
  end

  test 'facebook signup email already exists' do
    email = 'my@email.com'
    create :user, email: email
    OmniAuth.config.add_mock :facebook, info: { email: email }
    assert_difference "User.count", 0 do
      get user_facebook_omniauth_authorize_path
      follow_redirect!
      follow_redirect!
      assert_select 'span', email
    end
  end

  test 'failure' do
    OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
    assert_difference "User.count", 0 do
      get user_facebook_omniauth_authorize_path
      follow_redirect!
      follow_redirect!
      assert_select 'div', /invalid_credentials/
    end
  end

  test 'email signup needs confirmation' do
    email = 'my@email.com'
    password = '12345678'
    assert_difference "User.count", 1 do
      assert_difference "ActionMailer::Base.deliveries.size", 1 do
        post user_registration_path, params: { user: { email: email, password: password, password_confirmation: password } }
        follow_redirect!
        assert_select 'div', t("devise.registrations.signed_up_but_unconfirmed")
        assert_select 'span', count: 0, text: email
      end
    end
  end
  ActionMailer::Base.deliveries.clear
end
