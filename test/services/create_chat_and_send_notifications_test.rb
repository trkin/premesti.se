require 'test_helper'
class CreateChatAndSendNotificationsTest < ActiveSupport::TestCase
  def test_create_chat_2_moves_send_notification
    m1 = create :move
    m2 = create :move
    result = nil
    assert_difference 'Chat.count', 1 do
      assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
        result = CreateChatAndSendNotifications.new(m1, [m2]).perform
      end
    end
    assert_equal_when_sorted_by_id result.chat.moves, [m1, m2]
    email = give_me_last_mail_and_clear_mails
    assert_match Regexp.new(t('user_mailer.new_match.chat_link')), email.html_part.body.to_s
  end

  def test_create_chat_3_moves_send_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    result = nil
    assert_difference 'Chat.count', 1 do
      assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
        result = CreateChatAndSendNotifications.new(m1, [m2, m3]).perform
      end
    end
    assert_equal_when_sorted_by_id result.chat.moves, [m1, m2, m3]
    chat_mail1, chat_mail2 = all_mails
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail1.html_part.decoded
    assert_match Rails.application.routes.url_helpers.chat_url(result.chat), chat_mail2.html_part.decoded
  end

  def test_create_chat_2_moves_existing_send_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    chat = create :chat
    chat.moves << m1
    chat.moves << m2
    assert_difference 'Chat.count', 1 do
      result = CreateChatAndSendNotifications.new(m1, [m3]).perform
      assert_equal_when_sorted_by_id result.chat.moves, [m1, m3]
    end
  end

  def test_existing_chat_2_moves_no_notification
    m1 = create :move
    m2 = create :move
    chat = create :chat
    chat.moves << m1
    chat.moves << m2
    assert_difference 'Chat.count', 0 do
      result = CreateChatAndSendNotifications.new(m1, [m2]).perform
      refute result.success?
    end
  end

  def test_existing_chat_with_3_moves_no_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    chat = create :chat
    chat.moves << m1
    chat.moves << m2
    chat.moves << m3
    assert_difference 'Chat.count', 0 do
      result = CreateChatAndSendNotifications.new(m1, [m2, m3]).perform
      refute result.success?
    end
  end

  def test_existing_chat_with_3_moves_2_moves_no_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    chat = create :chat
    chat.moves << m1
    chat.moves << m2
    chat.moves << m3
    assert_difference 'Chat.count', 0 do
      result = CreateChatAndSendNotifications.new(m1, [m2]).perform
      refute result.success?
    end
  end
end
