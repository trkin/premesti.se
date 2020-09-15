require 'test_helper'
class CreateChatAndSendNotificationsJobTest < ActiveSupport::TestCase
  def test_when_move_does_not_exists
    m1 = create :move
    result = CreateChatAndSendNotificationsJob.perform_now m1.id, ['12']
    refute result
    result = CreateChatAndSendNotificationsJob.perform_now m1.id, ['12', m1.id]
    refute result
    result = CreateChatAndSendNotificationsJob.perform_now '12', [m1.id]
    refute result
    result = CreateChatAndSendNotificationsJob.perform_now m1.id, [m1.id]
    assert result
  end
end
