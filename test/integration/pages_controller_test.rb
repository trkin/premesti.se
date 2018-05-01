require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get '/'
    assert_response :success
    assert_select 'label', t('neo4j.attributes.landing_signup.current_location')
  end

  test 'landing signup success' do
    email = 'my@email.com'
    group = create :group
    params = {
      email: email,
      password: '1234567',
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group_age: group.age,
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

  test 'landing signup missing params render errors' do
    params = { email: '' }
    post landing_signup_path, params: { landing_signup: params }
    assert_response :success
    assert_select '#alert-debug', /#{t('errors.messages.blank')}/
  end

  test 'landing signup already existing email and valid password' do
    email = 'my@email.com'
    password = '1234567'
    create :user, email: email, password: password
    group = create :group
    params = {
      email: email,
      password: password,
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group_age: group.age,
    }
    assert_difference "User.count", 0 do
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

  test 'redirect to dashboard for authenticated users' do
    user = create :user
    login_as user
    get '/'
    assert_redirected_to dashboard_path
  end
end
