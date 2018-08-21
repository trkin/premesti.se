require 'test_helper'

class MoveTest < ActiveSupport::TestCase
  test 'check same age' do
    from_group1 = build :group, age: 1
    move = build :move, from_group: from_group1
    assert move.valid?

    group1 = build :group, age: 1
    move.to_groups << group1
    assert move.valid?

    group2 = build :group, age: 2
    move.to_groups << group2
    assert_not move.valid?
  end

  test '#destroy_to_group_and_archive_chats' do
    move = create :move
    location_b = create :location
    location_c = create :location
    group_b = create :group, location: location_b, age: move.from_group.age
    group_c = create :group, location: location_c, age: move.from_group.age
    move.to_groups << group_b
    move.to_groups << group_c
    move.save!
    move_b = create :move, from_group: group_b
    move_c = create :move, from_group: group_c
    chat = Chat.create_for_moves [move, move_b]
    chat_c = Chat.create_for_moves [move, move_c]
    chat_bc = Chat.create_for_moves [move_c, move, move_b]
    archived_chat = Chat.create_for_moves [move, move_b]
    archived_chat.archived!
    archived_chat.save!
    archived_reason = Move::ARCHIVED_REASONS.second

    move.destroy_to_group_and_archive_chats group_b, archived_reason

    assert_equal :archived, chat.reload.status
    assert_equal chat.messages.first.text, t('user_archived_chat_with_message', location: move.from_group.location.name, message: t(archived_reason))
    assert_equal :archived, chat_bc.reload.status
    assert_equal chat_bc.messages.first.text, t('user_archived_chat_with_message', location: move.from_group.location.name, message: t(archived_reason))
    assert_equal :active, chat_c.reload.status
    assert_equal chat_c.messages.count, 0
    assert_equal :archived, archived_chat.status
    assert_equal archived_chat.messages.count, 0
  end

  test '#destroy_and_archive_chats' do
    move = create :move
    another_move = create :move
    yet_another_move = create :move
    chat = Chat.create_for_moves [move, another_move]
    another_chat = Chat.create_for_moves [yet_another_move, move, another_move]
    archived_chat = Chat.create_for_moves [move, another_move]
    archived_chat.archived!
    archived_chat.save!
    archived_reason = Move::ARCHIVED_REASONS.second

    move.destroy_and_archive_chats archived_reason

    assert_equal :archived, chat.reload.status
    assert_equal chat.messages.first.text, t('user_archived_chat_with_message', location: move.from_group.location.name, message: t(archived_reason))
    assert_equal :archived, another_chat.reload.status
    assert_equal another_chat.messages.first.text, t('user_archived_chat_with_message', location: move.from_group.location.name, message: t(archived_reason))
    assert_equal :archived, archived_chat.reload.status
    assert_equal archived_chat.messages.count, 0
  end
end

