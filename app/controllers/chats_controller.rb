class ChatsController < ApplicationController
  before_action :_set_chat

  def show
    @message_decorator = MessageDecorator.new Message.new
  end

  def create_message
    @message_decorator = MessageDecorator.new Message.new _message_params
    if @message_decorator.save_and_send_notifications
      flash.now[:notice] = t_crud('success_create', Message)
    else
      flash.now[:alert] = @message_decorator.errors.full_messages.join(', ')
    end
  end

  def report_message
    message = @chat.messages.find params[:message_id]
    if params[:cancel_report]
      message.cancel_report
      redirect_to chat_path(@chat), notice: t('we_cancel_report_successfully')
    else
      message.report_by current_user
      redirect_to chat_path(@chat), notice: t('we_received_report_successfully')
    end
  end

  def archive_message
    message = @chat.messages.where(user: current_user).find params[:message_id]
    message.archived!
    message.save!
    redirect_to chat_path(@chat), notice: t_crud('success_archived', Message)
  end

  def destroy
    raise 'only_development' unless Rails.env.development?

    @chat.destroy
    redirect_to dashboard_path
  end

  def archive
    Notify.message "other_reason: #{params[:other_reason]}", current_user.email, chat_url(@chat) if params[:other_reason].present?
    @chat.archive_all_for_user_and_reason current_user, params[:commit]
    redirect_to dashboard_path
  end

  def _set_chat
    @chat = if current_user.admin?
              Chat.find params[:id]
            else
              @current_user.moves.chats.where(id: params[:id]).first
            end
    redirect_to root_path, alert: t('this_move_does_not_belong_to_you') unless @chat
  end

  def _message_params
    params.require(:message).permit(
      :text
    ).merge(
      user: @chat.moves.user.find_by(id: current_user.id),
      chat: @chat,
    )
  end
end
