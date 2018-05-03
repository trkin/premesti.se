class DashboardController < ApplicationController
  def index
    @moves = current_user.moves
    @chats = current_user.moves.chats
  end
end
