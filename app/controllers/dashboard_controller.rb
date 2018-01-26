class DashboardController < ApplicationController
  def index
    @moves = current_user.moves
  end
end
