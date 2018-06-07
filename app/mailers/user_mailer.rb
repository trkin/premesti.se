class UserMailer < ApplicationMailer
  def landing_signup(move)
    @move = move
    @confirmation_token = @move.user.generate_new_confirmation_token! unless @move.user.confirmed?

    mail to: @move.user.email
  end

  def new_match(move, chat)
    @move = move
    @chat = chat
    mail to: @move.user.email, subject: "#{t('new_match')} #{@move.from_group.location.name}"
  end
end
