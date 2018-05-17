require 'test_helper'
class CreateChatAndSendNotificationsTest < ActiveSupport::TestCase
  def test_create_chat_2_moves_send_notification
    m1 = create :move
    m2 = create :move
    assert_difference 'Chat.count', 1 do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        result = CreateChatAndSendNotifications.new(m1, [m2]).perform
        assert_equal result.chat.moves, [m1, m2]
        email = ActionMailer::Base.deliveries.first
        assert_match Regexp.new(t('user_mailer.new_match.chat_link')), email.html_part.body.to_s
      end
    end
  end

  def test_create_chat_3_moves_send_notification
    m1 = create :move
    m2 = create :move
    m3 = create :move
    assert_difference 'Chat.count', 1 do
      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        result = CreateChatAndSendNotifications.new(m1, [m2, m3]).perform
        assert_equal result.chat.moves, [m1, m2, m3]
        email = ActionMailer::Base.deliveries.first
        assert_match Regexp.new(t('user_mailer.new_match.chat_link')), email.html_part.body.to_s
      end
    end
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
      assert_equal result.chat.moves, [m1, m3]
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
