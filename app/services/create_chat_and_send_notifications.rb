class CreateChatAndSendNotifications
  class Result
    attr_reader :message, :chat
    def initialize(message, chat = nil)
      @message = message
      @chat = chat
    end

    def success?
      true
    end
  end

  class Error < Result
    def success?
      false
    end
  end

  def initialize(move, moves)
    @move = move
    @moves = moves
  end

  def perform
    chat = Chat.find_existing_for_moves(@moves + [@move])
    return Error.new(ApplicationController.helpers.t('neo4j.errors.messages.already_exists')) if chat.present?
    chat = Chat.create_for_moves(@moves + [@move])
    send_notification(chat) if chat
    Result.new 'OK', chat
  end

  def send_notification(chat)
    @moves.each do |move|
      UserMailer.new_match(move.id, chat.id).deliver_later
    end
  end

  def self.perform_all
    matches = FindMatchesInAllMoves.perform
    matches.each do |moves|
      new(moves).perform
    end
  end
end
