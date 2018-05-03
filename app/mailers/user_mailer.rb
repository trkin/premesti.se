class UserMailer < ApplicationMailer
  def landing_signup(move)
    @move = move
    unless @move.user.confirmed?
      @confirmation_token = @move.user.generate_new_confirmation_token!
    end

    mail to: @move.user.email
  end

  def new_match(move, chat)
    @move = move
    @chat = chat
    mail to: @move.user.email
  end
end
