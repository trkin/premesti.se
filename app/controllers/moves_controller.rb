class MovesController < ApplicationController
  before_action :set_move

  def show; end

  def create_to_group
    location = Location.find params[:to_location_id]
    group = location.groups.find_by age: @move.from_group.age
    @move.to_groups << group
    redirect_to move_path(@move)
  end

  def destroy_to_group
    group = @move.to_groups.find params[:to_group_id]
    @move.to_groups.delete group
    redirect_to move_path(@move)
  end

  private

  def set_move
    @move = current_user.moves.where(id: params[:id]).first
  end
end
