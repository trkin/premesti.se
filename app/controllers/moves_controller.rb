class MovesController < ApplicationController
  before_action :set_move

  def show; end

  private

  def set_move
    @move = current_user.moves.where(id: params[:id]).first
  end
end
