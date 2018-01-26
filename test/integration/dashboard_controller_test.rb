require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test 'unauthorized' do
    get dashboard_path
    assert_response :redirect
  end

  test 'see existing move' do
    user = create :user
    move = create :move, user: user
    sign_in user
    get dashboard_path
    assert_response :success
    assert_select 'a', /#{move.from_group.location.name}/
  end
end
