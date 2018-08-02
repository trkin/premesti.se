class UserMailer < ApplicationMailer
  def landing_signup(move_id)
    @move = Move.find move_id
    mailer_locale @move.user.locale
    @confirmation_token = @move.user.generate_new_confirmation_token! unless @move.user.confirmed?

    mail to: @move.user.email
  end

  def new_match(move_id, chat_id)
    @move = Move.find move_id
    @chat = Chat.find chat_id
    mailer_locale @move.user.locale
    mail to: @move.user.email, subject: "#{t('new_match')} #{@move.from_group.location.name}"
  end
end
