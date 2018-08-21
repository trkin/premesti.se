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
end
