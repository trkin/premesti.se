require 'test_helper'
class CreateChatAndSendNotificationsTest < ActiveSupport::TestCase
  def test_create_chat_2_moves_send_notification
    m1 = create :move
    m2 = create :move
    result = nil
    assert_difference 'Chat.count', 1 do
      assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
        result = CreateChatAndSendNotifications.new(m1, [m2]).perform
      end
    end
    assert_equal_when_sorted_by_id result.chat.moves, [m1, m2]
    chat_mail1, chat_mail2 = give_me_all_mail_and_clear_mails
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail1.html_part.decoded
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail2.html_part.decoded
  end

  def test_create_chat_2_moves_unsubscribed
    m1 = create :move
    m2 = create :move
    m1.user.subscribe_to_new_match = false
    m1.user.save!
    result = nil
    assert_difference 'Chat.count', 1 do
      assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
        result = CreateChatAndSendNotifications.new(m1, [m2]).perform
      end
    end
    assert_equal_when_sorted_by_id result.chat.moves, [m1, m2]
    chat_mail1, chat_mail2 = give_me_all_mail_and_clear_mails
    assert_nil chat_mail2
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail1.html_part.decoded
  end

  def test_create_chat_3_moves_send_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    result = nil
    assert_difference 'Chat.count', 1 do
      assert_performed_jobs 3, only: ActionMailer::DeliveryJob do
        result = CreateChatAndSendNotifications.new(m1, [m2, m3]).perform
      end
    end
    assert_equal_when_sorted_by_id result.chat.moves, [m1, m2, m3]
    chat_mail1, chat_mail2, chat_mail3 = give_me_all_mail_and_clear_mails
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail1.html_part.decoded
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail2.html_part.decoded
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail3.html_part.decoded
  end

  def test_create_chat_2_moves_existing_send_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    _chat = Chat.create_for_moves m1, m2
    assert_difference 'Chat.count', 1 do
      result = CreateChatAndSendNotifications.new(m1, [m3]).perform
      assert_equal_when_sorted_by_id result.chat.moves, [m1, m3]
    end
  end

  def test_existing_chat_2_moves_no_notification
    m1 = create :move
    m2 = create :move
    _chat = Chat.create_for_moves m1, m2
    assert_difference 'Chat.count', 0 do
      result = CreateChatAndSendNotifications.new(m1, [m2]).perform
      refute result.success?
    end
  end

  def test_existing_chat_with_3_moves_no_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    _chat = Chat.create_for_moves [m1, m2, m3]
    assert_difference 'Chat.count', 0 do
      result = CreateChatAndSendNotifications.new(m1, [m2, m3]).perform
      refute result.success?
    end
  end

  def test_existing_chat_with_3_moves_2_moves_no_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    _chat = Chat.create_for_moves m1, m2, m3
    assert_difference 'Chat.count', 0 do
      result = CreateChatAndSendNotifications.new(m1, [m2]).perform
      refute result.success?
    end
  end
end
