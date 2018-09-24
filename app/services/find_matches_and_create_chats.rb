class FindMatchesAndCreateChats
  class Result
    attr_reader :message
    def initialize(message)
      @message = message
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

  def initialize(move, group)
    @move = move
    @group = group
  end

  def perform(max_length_of_the_rotation: nil)
    return 'ignored_sending_notifications_unconfirmed_user' unless @move.user.confirmed?
    results = FindMatchesForOneMove.perform @move, target_group: @group, max_length_of_the_rotation: max_length_of_the_rotation
    results.each do |moves|
      CreateChatAndSendNotifications.new(@move, moves).perform
    end
  end
end
