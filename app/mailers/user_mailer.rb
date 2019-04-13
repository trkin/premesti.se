class UserMailer < ApplicationMailer
  def landing_signup(move_id)
    @move = Move.find_by id: move_id
    # it could be that move is deleted before we send email
    return unless @move

    @confirmation_token = @move.user.generate_new_confirmation_token! unless @move.user.confirmed?

    mail to: @move.user.email
  end

  def new_match(move_id, missing_move_id, chat_id)
    @move = Move.find move_id
    @missing_move = Move.find missing_move_id
    @chat = Chat.find chat_id
    @tag = __method__
    return unless @move.user.subscribe_to_new_match

    # when subject use I18n.t, define it with Proc becaus we use with_locale
    mail to: @move.user.email, subject: -> { "[#{t('site_title')}] #{t('new_match')} #{@move.from_group.location.name}" }
  end

  def new_message(move_id, message_id)
    @move = Move.find move_id
    @message = Message.find message_id
    @tag = __method__
    return unless @move.user.subscribe_to_new_match

    # when subject use I18n.t, define it with Proc becaus we use with_locale
    mail to: @move.user.email, subject: -> { "[#{t('site_title')}] #{t('new_message')} #{@move.from_group.location.name}" }
  end

  def notification(user_id, subject, message, tag)
    @user = User.find user_id
    @subject = _translate_message_from_cyr_to_lat @user.locale, subject
    @message = _translate_message_from_cyr_to_lat @user.locale, message
    @tag = tag
    return unless @user.subscribe_to_news_mailing_list

    # when subject use I18n.t, define it with Proc becaus we use with_locale
    mail to: @user.email, subject: -> { "[#{t('site_title')}] #{subject}" }
  end

  def _translate_message_from_cyr_to_lat(locale, message)
    case locale
    when 'sr'
      message
    else
      message.to_lat
    end
  end
end
