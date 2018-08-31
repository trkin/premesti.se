require "application_system_test_case"

class ChatsTest < ApplicationSystemTestCase
  test 'create some messages and archive chat and move' do
    age = 1
    user = create :user
    location_a = create :location
    location_b = create :location
    location_c = create :location
    group_a = create :group, location: location_a, age: age
    group_b = create :group, location: location_b, age: age
    group_c = create :group, location: location_c, age: age
    move_ab = create :move, user: user, from_group: group_a, to_groups: [group_b]
    move_bc = create :move, from_group: group_b, to_groups: [group_c]
    move_ca = create :move, from_group: group_c, to_groups: [group_a]
    chat = Chat.create_for_moves [move_ab, move_bc, move_ca]
    sign_in user
    visit dashboard_path

    assert_selector 'a', text: chat.name_for_user(user)
    assert_selector 'a', text: move_ab.group_age_and_locations
    click_on chat.name_for_user user

    fill_in 'new-message-input', with: 'hello there'
    click_on t_crud('send', Message)
    fill_in 'new-message-input', with: 'this_will_be_deleted'
    click_on t_crud('send', Message)
    # find("a[title='#{t_crud('delete', Message)}']", visible: false, match: :first).click

    # now we archive and also delete to_group
    click_on t_crud('delete', Chat)
    click_on t(Move::ARCHIVED_REASONS.first)
    refute_selector 'a', text: chat.name_for_user(user)
    refute_selector 'a', text: move_ab.group_age_and_locations

    # now we are creating same to_group and it should create another chat
    move_ab.reload
    click_on move_ab.group_age_and_locations
    find('label', text: t('add_requested_location')).click
    select2_ajax location_b.name_with_address, selector:
      'span.select2-selection__rendered', text:
      t('activemodel.attributes.landing_signup.to_location')
    click_on t('add')
    visit dashboard_path
    assert_selector 'a', text: chat.name_for_user(user)
    pause
  end
end
