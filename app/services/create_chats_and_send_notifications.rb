class CreateChatsAndSendNotifications
  def initialize(moves)
    @moves = moves
  end

  def perform
    chat = create_chat_if_not_exists_for_that_moves
    send_notification(chat) if chat
    chat
  end

  def create_chat_if_not_exists_for_that_moves
    chat = Chat.find_existing_for_moves(@moves)
    return false if chat.present?
    Chat.create_for_moves(@moves)
  end

  def send_notification(chat)
    chat.moves.each do |move|
      UserMailer.new_match(move, chat).deliver_now
    end
  end

  def self.perform_all
    matches = FindMatches.perform
    matches.each do |moves|
      new(moves).perform
    end
  end
end
