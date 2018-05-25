module MailerHelpers
  def clear_mails
    ActionMailer::Base.deliveries = []
  end

  def all_mails
    ActionMailer::Base.deliveries.last
  end

  # last_email is renamed to last_mail
  def last_mail
    ActionMailer::Base.deliveries.last
  end

  # some usage is like
  # mail = give_me_last_mail_and_clear_mails
  # assert_equal [email], mail.to
  # assert_match t('user_mailer.landing_signup.confirmation_text'), mail.html_part.decoded
  # confirmation_link = mail.html_part.decoded.match(
  #   /(http:.*)">#{t("confirm_email")}/
  # )[1]
  # visit confirmation_link
  def give_me_last_mail_and_clear_mails
    mail = last_mail
    clear_mails
    mail
  end
end
class ActionDispatch::IntegrationTest
  include MailerHelpers
end
