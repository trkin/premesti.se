class MessageDecorator < SimpleDelegator
  def message
    __getobj__
  end

  def save_and_send_notifications
    message.save && _send_to_chat_channel && _send_to_email
  end

  def _send_to_chat_channel
    ActionCable.server.broadcast(
      "chat_#{message.chat.id}_channel",
      message: ChatsController.render(partial: 'chats/message', locals: { message: message }, layout: false).squish
    )
  end

  def _send_to_email
    message.chat.moves.each do |move|
      next if move.user == message.user
      UserMailer.new_message(move.id, message.id).deliver_later
    end
    true
  end
end
