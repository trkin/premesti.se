class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def assert_user_logged_in_with_email(email)
    assert_selector 'a#userDropdown', email.split('@').first
  end
end
