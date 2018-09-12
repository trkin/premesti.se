module MailerHelpers
  def clear_mails
    ActionMailer::Base.deliveries = []
  end

  # if you deliver_now you can
  # assert_difference 'all_mails.count', 1 do
  # and for background deliver_later you need to assert perform or enqueue
  # inherit from ActiveJob::TestCase
  # or include ActiveJob::TestHelper
  # assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
  def all_mails
    all = ActionMailer::Base.deliveries
    clear_mails
    all
  end

  # last_email is renamed to last_mail
  def last_mail
    raise 'you_should_use_give_me_last_mail_and_clear_mails'
    # ActionMailer::Base.deliveries.last
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
    mail = ActionMailer::Base.deliveries.last
    clear_mails
    mail
  end
end
