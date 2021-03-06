class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.mailer_sender, bcc: Rails.application.secrets.exception_recipients
  layout 'mailer'
  add_template_helper MailerHelper

  def mail(attr)
    user = _find_user
    data_for_token = { move_id: @move&.id }
    unsubscribe_type = UserUnsubscribe.find_unsubscribe_type @tag
    @unsubscribe_token = UserUnsubscribe.generate_token user.id, unsubscribe_type, data_for_token
    res = nil
    I18n.with_locale user.locale do
      domain = Constant::DOMAINS[Rails.env.production? ? :production : :development][I18n.locale]
      ActionMailer::Base.default_url_options[:host] = domain
      attr[:subject] = attr[:subject].call if attr[:subject].is_a? Proc
      res = super(attr)
    end
    text = ActionController::Base.helpers.strip_tags(res.body.to_s).split.join ' '
    EmailMessage.create user: user, to: attr[:to], subject: attr[:subject], body: res.body.to_s, text: text, tag: @tag
    res
  end

  def _find_user
    return @user if @user.present?
    return @move.user if @move.present?

    raise 'can_not_find_user_receiver'
  end
end
