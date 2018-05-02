class MovesController < ApplicationController
  before_action :set_move, except: %i[create_from_group]

  def show; end

  def create_to_group
    redirect_to move_path(@move), alert: t_crud('please_select', Location) and return unless params[:to_location_id].present?
    location = Location.find params[:to_location_id]
    group = location.groups.find_by age: @move.from_group.age
    if @move.add_to_group group
      redirect_to move_path(@move), notice: t_crud('success_create', Group)
    else
      redirect_to move_path(@move), alert: @move.errors.full_messages.join(', ')
    end
  end

  def destroy_to_group
    group = @move.to_groups.find params[:to_group_id]
    @move.to_groups.delete group
    redirect_to move_path(@move), notice: t_crud('success_delete', Location)
  end

  def create_from_group
    from_location = Location.find params[:from_location_id]
    from_group = from_location.groups.find_by age: params[:from_group_age]
    move = Move.new user: current_user, from_group: from_group
    if move.save
      redirect_to move_path(move), notice: t_crud('success_create', Location)
    else
      redirect_to dashboard_path, alert: move.errors.full_messages.join(', ')
    end
  end

  private

  def set_move
    @move = current_user.moves.where(id: params[:id]).first
  end
end
