require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get '/'
    assert_response :success
  end

  test 'landing signup success' do
    email = 'my@email.com'
    group = create :group
    params = {
      email: email,
      password: '1234567',
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group: group.id,
    }
    assert_difference "User.count", 1 do
      assert_difference "Move.count", 1 do
        assert_difference "ActionMailer::Base.deliveries.size", 1 do
          post landing_signup_path, params: { landing_signup: params }
        end
      end
    end
    assert_response :redirect
    assert_redirected_to dashboard_path
    ActionMailer::Base.deliveries.clear
  end

  test 'landing signup missing params' do
    params = { email: 'a' }
    post landing_signup_path, params: { landing_signup: params }
    assert_response :success
  end
end
