require 'test_helper'
require 'minitest/autorun'
class AddToGroupAndSendNotificationsTest < ActiveSupport::TestCase
  def test_validate_that_group_can_be_added_empty
    move = build :move

    refute AddToGroupAndSendNotifications.new(move, nil)._validate_that_group_can_be_added?
  end

  def test_validate_that_group_can_be_added_same_as_from_group
    # we need in db because of <<
    move = create :move

    refute AddToGroupAndSendNotifications.new(move, move.from_group)._validate_that_group_can_be_added?
  end

  def test_validate_that_group_can_be_added_already_included
    # we need in db because of <<
    move = create :move
    same_age_group = create :group, age: move.from_group.age
    move.to_groups << same_age_group

    refute AddToGroupAndSendNotifications.new(move, same_age_group)._validate_that_group_can_be_added?
  end

  def test_validate_that_group_can_be_added_same_age
    # we can not use build :move, since it's location would be the same as build
    # :group
    move = create :move
    same_age_group = create :group, age: move.from_group.age

    assert AddToGroupAndSendNotifications.new(move, same_age_group)._validate_that_group_can_be_added?
  end

  def test_ignore_sending_notification
    unconfirmed_user = create :unconfirmed_user
    move = create :move, user: unconfirmed_user
    same_age_group = create :group, age: move.from_group.age

    result = AddToGroupAndSendNotifications.new(move, same_age_group).perform

    refute result.success?
    assert_equal result.message, I18n.t('ignored_sending_notifications_unconfirmed_user')
  end

  def test_send_successfully
    move_ab = create :move
    move_ba = create :move
    same_age_group = create :group, age: move_ab.from_group.age
    FindMatchesForOneMove.stub :perform, [[move_ba]] do
      result = AddToGroupAndSendNotifications.new(move_ab, same_age_group).perform
      assert result.success?
      assert_equal result.message, I18n.t('request_created_and_sent_notifications_successfully', count: 1)
    end
  end
end
