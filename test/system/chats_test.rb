require 'application_system_test_case'

class ChatsTest < ApplicationSystemTestCase
  test 'create some messages and archive chat and move' do
    age = 1
    user = create :user
    location_a = create :location, name: 'location_a'
    location_b = create :location, name: 'location_b'
    location_c = create :location, name: 'location_c'
    group_a = create :group, location: location_a, age: age
    group_b = create :group, location: location_b, age: age
    group_c = create :group, location: location_c, age: age
    move_ab = create :move, user: user, from_group: group_a, to_groups: [group_b]
    move_bc = create :move, from_group: group_b, to_groups: [group_c]
    move_ca = create :move, from_group: group_c, to_groups: [group_a]
    chat = Chat.create_for_moves [move_ab, move_bc, move_ca]
    sign_in user
    visit dashboard_path
    assert_text chat.name_with_arrows
    assert_text move_ab.group_age_and_locations

    visit chat_path(chat)
    click_on t('ignore_all_and_see_chat')

    fill_in 'new-message-input', with: 'hello there'
    click_on t_crud('send', Message)
    fill_in 'new-message-input', with: 'this_will_be_deleted'
    click_on t_crud('send', Message)
    # find("a[title='#{t_crud('delete', Message)}']", visible: false, match: :first).click

    # now we archive and also delete to_group
    text = ActionController::Base.helpers.strip_tags t('delete_chat_and_my_move')
    click_on text
    click_on t(Move::FAILED_ARCHIVED_REASONS.first)
    refute_text chat.name_with_arrows
    refute_text move_ab.group_age_and_locations

    # now we are creating same to_group and it should create another chat
    move_ab.reload
    visit move_path(move_ab)
    find('label', text: t('add_request_location_for_move_from_location_name', location_name: move_ab.from_group.location.name)).click
    select2_ajax location_b.name_with_address, text: nil, selector: '#select2-to_location_id-container'
    click_on t('add')
    visit dashboard_path
    assert_text move_ab.group_age_and_locations
  end
end
