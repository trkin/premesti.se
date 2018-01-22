require 'test_helper'

class AdminPagesControllerTest < ActionDispatch::IntegrationTest
  test 'redirect unless params city present' do
    user = create :user, :admin
    login_as user
    get admin_locations_path
    assert_response :redirect
    assert_redirected_to admin_dashboard_path
  end
end
