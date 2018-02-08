require 'test_helper'

class AdminPagesControllerTest < ActionDispatch::IntegrationTest
  test 'redirect unless params city present' do
    user = create :user, :admin
    login_as user
    get admin_locations_path
    assert_response :redirect
    assert_redirected_to admin_dashboard_path
  end

  test 'create location' do
    user = create :user, :admin
    city = create :city
    login_as user
    assert_difference "Location.count", 1 do
      post admin_locations_path, xhr: true, params: { location: attributes_for(:location) }.merge(city_id: city.id)
    end
  end

  test 'create location and groups' do
    user = create :user, :admin
    city = create :city
    login_as user
    assert_difference "Group.count", 3 do
      post admin_locations_path, xhr: true, params: {
        location: attributes_for(:location).merge(group_ages: "1 2 3")
      }.merge(city_id: city.id)
    end
  end
end
