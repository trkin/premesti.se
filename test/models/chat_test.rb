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
    m_ab = create :move, from_group: g_a, to_groups: [g_x, g_b]
    _m_bc = create :move, from_group: g_b, to_groups: [g_c]
    _m_cd = create :move, from_group: g_c, to_groups: [g_d, g_y, g_z]
    _m_da = create :move, from_group: g_d, to_groups: [g_b, g_a, g_z]

    result = FindMatchesForOneMove.perform(m_ab, target_group: g_b, max_length_of_the_rotation: 4)
    moves = result.first + [m_ab]
    chat = Chat.create_for_moves moves
    expected = [g_a, g_b, g_c, g_d, g_a].map { |g| g.location.name }.join " #{Constant::ARROW_CHAR} "
    assert_equal expected, chat.name_with_arrows(moves)
  end
end
