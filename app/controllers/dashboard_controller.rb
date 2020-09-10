class DashboardController < ApplicationController
  def index; end

  def resend_confirmation_instructions
    current_user.send_confirmation_instructions
    redirect_to dashboard_path, notice: t('devise.registrations.signed_up_but_unconfirmed')
  end

  def moves_for_age
    return [] unless params[:age].present?

    @moves = \
      Move
      .query_as(:m)
      .match('(m)-[:CURRENT]-(g)')
      .where(g: { age: params[:age].to_i })
      .proxy_as(Move, :m)
      .page(params[:page])
  end

  def buy_me_a_coffee
    if params[:chat_id]
      @chat = Chat.find params[:chat_id]
      if current_user.shared_chats.include?(@chat)
        redirect_to @chat and return
      end
    end
  end

  def shared_callback
    model, id = params[:model_id].split(':')
    case model
    when 'chat_id'
      chat = Chat.find id
      if current_user.shared_chats.include?(chat)
        message = 'user already shared this chat'
      else
        message = 'adding chat to shared_chats'
        current_user.shared_chats << chat
      end
    else
      message = "model in params[:model_id]=#{params[:model_id]} is not correct"
    end
    render html: message
  end
end
