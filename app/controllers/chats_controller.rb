class ChatsController < ApplicationController
  before_action :_set_chat

  def show
    @message_decorator = MessageDecorator.new Message.new
  end

  def create_message
    @message_decorator = MessageDecorator.new Message.new _message_params
    if @message_decorator.save_and_send_notifications
      redirect_to chat_path(@chat), notice: t_crud('success_create', Message)
    else
      render :show
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

  def destroy_message
    message = @chat.messages.where(user: current_user).find params[:message_id]
    message.destroy
    redirect_to chat_path(@chat), notice: t_crud('success_delete', Message)
  end

  def destroy
    raise 'only_development' unless Rails.env.development?
    @chat.destroy
    redirect_to dashboard_path
  end

  def _set_chat
    @chat = if current_user.admin?
              Chat.find params[:id]
            else
              @current_user.moves.chats.where(id: params[:id]).first
            end
    raise Neo4j::ActiveNode::Labels::RecordNotFound unless @chat
  end

  def _message_params
    params.require(:message).permit(
      :text
    ).merge(
      user: current_user,
      chat: @chat,
    )
  end
end
