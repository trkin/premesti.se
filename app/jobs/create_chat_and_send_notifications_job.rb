class CreateChatAndSendNotificationsJob < ApplicationJob
  def perform(move_id, moves_ids)
    move = Move.find_by id: move_id
    moves = moves_ids.map do |move_id|
      Move.find_by id: move_id
    end
    return false if move.nil? || !moves.all?

    CreateChatAndSendNotifications.new(move, moves).perform
  end
end
