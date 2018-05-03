class ChatsController < ApplicationController
  before_action :_set_chat

  def show
    @message = Message.new
  end

  def create_message
    @message = Message.new _message_params
    if @message.save
      redirect_to chat_path(@chat), notice: t_crud('success_create', Message)
    else
      render :show
    end
  end

  def destroy_message
    message = @chat.messages.where(user: current_user).find params[:message_id]
    message.destroy
    redirect_to chat_path(@chat), notice: t_crud('success_delete', Message)
  end

  def _set_chat
    @chat = current_user.moves.chats.where(id: params[:id]).first
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
