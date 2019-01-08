require 'application_system_test_case'

class AdminUsersTest < ApplicationSystemTestCase
  test 'see active, archived and deleted_move chat messages' do
    user = create :user, admin: true
    move = create :move, user: user
    other_move = create :move

    chat = Chat.create_for_moves [move, other_move]
    create :message, chat: chat, user: user, text: 'active_chat'

    archived_chat = Chat.create_for_moves [move, other_move]
    archived_chat.archived!
    archived_chat.save!
    create :message, chat: archived_chat, user: user, text: 'archived_chat'

    deleted_move = create :move, user: user
    deleted_move_chat = Chat.create_for_moves [deleted_move, other_move]
    create :message, chat: deleted_move_chat, user: user, text: 'deleted_move_chat'
    deleted_move.destroy_and_archive_chats 'added_move_by_mistake'

    sign_in user
    visit admin_user_path user
    assert_selector 'ul#active_chat', text: 'active_chat'
    assert_selector 'ul#archived_chat', text: 'archived_chat'
    # we completelly destroy move assert_selector 'ul#deleted_move_chat', text: 'deleted_move_chat'
  end
end
