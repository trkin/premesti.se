class MovesController < ApplicationController
  before_action :set_move, except: %i[create_from_group]

  def show; end

  def create_to_group
    redirect_to move_path(@move), alert: t_crud('please_select', Location) and return unless params[:to_location_id].present?
    if @move.add_to_group Group.find_or_create_by_location_id_and_age(params[:to_location_id], @move.from_group.age)
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
    move = Move.new(
      from_group: Group.find_or_create_by_location_id_and_age(params[:from_location_id], params[:from_group_age]),
      user: current_user,
    )
    if move.save
      redirect_to move_path(move), notice: t_crud('success_create', Location)
    else
      redirect_to dashboard_path, alert: move.errors.full_messages.join(', ')
    end
  end

  def destroy
    if @move.destroy_and_update_chats
      redirect_to dashboard_path, notice: t_crud('success_delete', Move)
    else
      redirect_to dashboard_path, alert: @move.errors.full_messages.join(', ')
    end
  end

  private

  def set_move
    @move = current_user.moves.where(id: params[:id]).first
    raise Neo4j::ActiveNode::Labels::RecordNotFound unless @move
  end
end
