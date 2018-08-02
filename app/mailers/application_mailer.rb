class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.mailer_sender
  layout 'mailer'
  add_template_helper MailerHelper

  def mailer_locale(locale)
    I18n.locale = locale
  end
end
