class ContactForm
  include ActiveModel::Model
  include Recaptcha::Verify

  attr_accessor :email, :text, :g_recaptcha_response, :current_user, :remote_ip
  validates_format_of :email, with: Devise.email_regexp
  validates :text, :email, presence: true

  def save
    verify_recaptcha model: self, response: g_recaptcha_response
    return false if errors.present?
    return false unless valid?

    _send_notification
    true
  end

  def request
    OpenStruct.new remote_ip: remote_ip
  end

  def env
    nil
  end

  def _send_notification
    Notify.message("contact_form #{email} @ #{Time.zone.now}", email, text, remote_ip, current_user)
  end
end
