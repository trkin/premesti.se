class CreateChatAndSendNotificationsJob < ApplicationJob
  def perform(move_id, moves_ids)
    move = Move.find move_id
    moves = moves_ids.map do |move_id|
      Move.find move_id
    end
    CreateChatAndSendNotifications.new(move, moves).perform
  end
end
