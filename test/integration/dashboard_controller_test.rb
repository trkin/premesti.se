require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test 'unauthorized' do
    get dashboard_path
    assert_response :redirect
  end

  test 'dashabord' do
    user = create :user
    sign_in user
    get dashboard_path
    assert_response :success
  end
end
