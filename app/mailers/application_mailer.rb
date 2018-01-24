class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.mailer_sender
  layout 'mailer'
  add_template_helper MailerHelper
end
