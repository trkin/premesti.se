class FindMatchesAndCreateChatsJob < ApplicationJob
  def perform(move, to_group)
    FindMatchesAndCreateChats.new(move, to_group).perform
  end
end
