require 'test_helper'

class ChatTest < ActiveSupport::TestCase
  test '#find_existing_for_moves do not find archived' do
    m1 = create :move
    m2 = create :move
    chat = Chat.create_for_moves [m1, m2]
    chat_archived = Chat.create_for_moves [m1, m2]
    chat_archived.archived!
    chat_archived.save!
    chat_archived.reload
    actual = Chat.find_existing_for_moves [m1, m2]
    assert_equal [chat], actual
  end

  test '#name_with_arrows' do
    g_a = create :group, age: 1
    g_b = create :group, age: 1
    g_c = create :group, age: 1
    g_d = create :group, age: 1
    # some noice
    g_x = create :group, age: 1
    g_y = create :group, age: 1
    g_z = create :group, age: 1
    m_ab = create :move, from_group: g_a, to_groups: [g_x]
    _m_bc = create :move, from_group: g_b, to_groups: [g_c]
    _m_cd = create :move, from_group: g_c, to_groups: [g_d, g_y, g_z]
    _m_da = create :move, from_group: g_d, to_groups: [g_b, g_a, g_z]

    result = AddToGroupAndSendNotifications.new(m_ab, g_b).perform max_length_of_the_rotation: 4
    assert result.success?
    chat = Chat.last

    expected = [g_d, g_a, g_b, g_c, g_d].map { |g| g.location.name }.join " -&gt; "
    assert_equal expected, chat.name_with_arrows
  end

  test '#create_for_moves' do
    m1 = create :move
    m1.user.initial_chat_message = 'HiFromMove1'
    m1.user.phone_number = '111111'
    m1.user.save!
    m2 = create :move
    m2.user.initial_chat_message = 'HiFromMove2'
    m2.user.phone_number = '222222'
    m2.user.save!
    chat = Chat.create_for_moves [m1, m2]
    assert_equal 3, chat.messages.size
    message2, message1, message_init = chat.messages
    assert_equal 'HiFromMove1', message1.text
    assert_equal 'HiFromMove2', message2.text
    assert_match(/222222.*111111/, message_init.text)
  end

  test '#can_see_chat' do
    moveAB = create :move
    moveBA = create :move
    chat = Chat.create_for_moves moveAB, moveBA
    moveAB.user.shared_chats << chat

    user = create :user
    admin_user = create :user, :admin
    buyed_a_coffee_user = create :user, buyed_a_coffee: true

    assert admin_user.can_see_chat(chat)
    assert buyed_a_coffee_user.can_see_chat(chat)
    assert moveAB.user.can_see_chat(chat)
    refute moveBA.user.can_see_chat(chat)
  end
end
