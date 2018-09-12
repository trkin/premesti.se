class UserMailer < ApplicationMailer
  def landing_signup(move_id)
    @move = Move.find move_id
    @confirmation_token = @move.user.generate_new_confirmation_token! unless @move.user.confirmed?

    mailer_locale @move.user.locale
    mail to: @move.user.email
  end

  def new_match(move_id, missing_move_id, chat_id)
    @move = Move.find move_id
    @missing_move = Move.find missing_move_id
    @chat = Chat.find chat_id
    mailer_locale @move.user.locale
    mail to: @move.user.email, subject: "#{t('new_match')} #{@move.from_group.location.name}"
  end

  def new_message(move_id, message_id)
    @move = Move.find move_id
    @message = Message.find message_id
    mailer_locale @move.user.locale
    mail to: @move.user.email, subject: "#{t('new_message')} #{@move.from_group.location.name}"
  end

  def notification(user_id, subject, message)
    @user = User.find user_id
    @subject = subject
    @message = message
    mail to: @user.email, subject: "[#{t('site_title')}] #{subject}"
  end
end
