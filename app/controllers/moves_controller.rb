class MovesController < ApplicationController
  before_action :set_move, except: %i[create_from_group]

  def show; end

  def create_to_group
    redirect_to move_path(@move), alert: t_crud('please_select', Location) && return unless params[:to_location_id].present?
    group = Group.find_or_create_by_location_id_and_age(params[:to_location_id], @move.from_group.age)
    result = AddToGroupAndSendNotifications.new(@move, group).perform
    if result.success?
      redirect_to move_path(@move), notice: result.message
    else
      redirect_to move_path(@move), alert: result.message
    end
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

  def destroy_to_group
    to_group = @move.to_groups.find params[:to_group_id]
    Notify.message "other_reason: #{params[:other_reason]}", current_user.email, move_url(@move), to_group: to_group.location.name if params[:other_reason].present?
    @move.destroy_to_group_and_archive_chats to_group, params[:commit]
    redirect_to move_path(@move), notice: t_crud('success_delete', Location)
  end

  def destroy
    Notify.message 'other_reason', other_reason: params[:other_reason], current_user: current_user.email, move: move_url(@move) if params[:other_reason].present?
    if @move.destroy_and_archive_chats params[:commit]
      redirect_to dashboard_path, notice: t_crud('success_delete', Move)
    else
      redirect_to dashboard_path, alert: @move.errors.full_messages.join(', ')
    end
  end

  private

  def set_move
    @move = current_user.moves.where(id: params[:id]).first
    return if @move
    alert = if Move.where(id: params[:id]).present?
              t('this_move_does_not_belong_to_you')
            else
              t('this_move_was_deleted')
            end
    redirect_to root_path, alert: alert
  end
end
