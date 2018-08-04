class MessageDecorator < SimpleDelegator
  def message
    __getobj__
  end

  def save_and_send_notifications
    message.save && _send_notifications
  end

  def _send_notifications
    message.chat.moves.each do |move|
      next if move.user == message.user
      UserMailer.new_message(move.id, message.id).deliver_later
    end
    true
  end
end
