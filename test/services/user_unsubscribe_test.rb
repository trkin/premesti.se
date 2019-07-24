require 'test_helper'
class UserUnsubscribeTest < ActiveSupport::TestCase
  def test_user_id_unsubscribe_type_and_data_from_token
    token = UserUnsubscribe.generate_token 1, :notifications_for_news, move_id: 1
    user_id, unsubscribe_type, data = UserUnsubscribe.user_id_unsubscribe_type_and_data_from_token token
    assert_equal 1, user_id
    assert_equal :notifications_for_news, unsubscribe_type
    assert_equal 1, data[:move_id]
  end

  def test_user_unsubscribe_from_move
    move = create :move
    assert_difference 'Move.count', -1 do
      result = UserUnsubscribe.new(move.user).perform :notifications_for_new_match, move_id: move.id
      assert_equal result.message, t_crud('success_delete', Move)
    end
  end

  def test_user_unsubscribe_from_move_when_data_is_wrong
    move = create :move
    assert_no_difference 'Move.count' do
      result = UserUnsubscribe.new(move.user).perform :notifications_for_new_match, move_id: '2'
      assert_equal result.message, t('this_move_was_deleted')
    end
  end
end
