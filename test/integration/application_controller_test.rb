require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'set locale' do
    get '/'
    assert_equal I18n.locale, I18n.default_locale

    # host! 'sr.localhost'
    # get '/'
    # assert_equal I18n.locale, :sr

    # host! 'localhost'
    # get '/'
    # assert_equal I18n.locale, I18n.default_locale
  end

  test 'sign_in_as' do
    target_user = create :user, email: 'target@email.com'
    get sign_in_as_path user_id: target_user.id
    follow_redirect!
    assert_select_alert_message t(:unauthorized)

    user = create :user
    sign_in user
    get sign_in_as_path user_id: target_user.id
    follow_redirect!
    assert_select_alert_message t(:unauthorized)

    user = create :user, admin: true
    sign_in user
    get sign_in_as_path user_id: target_user.id
    assert_response :redirect
    follow_redirect!
    assert_select_notice_message t(:successfully)
  end
end
