class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.mailer_sender
  layout 'mailer'
  add_template_helper MailerHelper

  def mailer_locale(locale)
    I18n.locale = locale
    domain = Constant::DOMAINS[Rails.env.to_sym][I18n.locale]
    ActionMailer::Base.default_url_options[:host] = domain
  end

  def mail(attr)
    user = _find_user
    res = super(attr)
    text = ActionController::Base.helpers.strip_tags(res.body.to_s).split.join ' '
    EmailMessage.create user: user, to: attr[:to], subject: attr[:subject], body: res.body.to_s, text: text
    res
  end

  def _find_user
    return @move.user if @move.present?
    raise 'can_not_find_user_receiver'
  end
end
