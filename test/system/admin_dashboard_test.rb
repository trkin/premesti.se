require 'application_system_test_case'

class LandingTest < ApplicationSystemTestCase
  test 'see admin links' do
    password = 'asdfasdf'
    user = create :user, password: password, admin: true
    manual_login user.email, password
    visit dashboard_path

    click_on user.email_username
    click_on t('admin_dashboard')
    assert_equal admin_dashboard_path, page.current_path
  end

  test 'non admin does not see admin links' do
    password = 'asdfasdf'
    user = create :user, password: password
    manual_login user.email, password
    visit dashboard_path

    refute_text t('admin_dashboard')
    visit admin_dashboard_path
    refute_text t('admin_dashboard')
    refute_equal admin_dashboard_path, page.current_path
  end

  test 'create location and group' do
    city = create :city
    password = 'asdfasdf'
    user = create :user, password: password, admin: true
    manual_login user.email, password
    visit admin_dashboard_path

    click_on city.name

    click_on t_crud('create', Location)
    fill_in Location.human_attribute_name('name'), with: 'My Location'
    fill_in Location.human_attribute_name('address'), with: 'My Address'
    click_on t('create')

    click_on t_crud('create', Group)
    fill_in Group.human_attribute_name('age'), with: 2
    fill_in Group.human_attribute_name('name'), with: 'my_group'
    click_on t('create')

    assert_text 'my_group'

    click_on 'my_group'
    page.accept_confirm { click_on t('delete') }

    refute_text 'my_group'
  end

  test 'create location with position on map' do
    city = create :city
    password = 'asdfasdf'
    user = create :user, password: password, admin: true
    manual_login user.email, password
    visit admin_dashboard_path

    click_on city.name
    click_on t_crud('create', Location)
    fill_in Location.human_attribute_name('name'), with: 'Spens'
    fill_in t('write_address_than_move_marker'), with: 'SPENS'
    page.execute_script "$('.pac-item').first().click()"

    # assert_selector 'dd', text: 'Spens'

    # location = Location.last
    # assert_in_delta 45.2472827, location.latitude
    # assert_in_delta 19.845571999999947, location.longitude
  end
end
