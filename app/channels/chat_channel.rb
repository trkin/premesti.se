class ChatChannel < ApplicationCable::Channel
  CHAT_TOPIC = 'chat'
  def subscribed
    stream_from CHAT_TOPIC
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
