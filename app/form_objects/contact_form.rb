class ContactForm
  include ActiveModel::Model
  attr_accessor :email, :text, :remote_ip
  validates_format_of :email, with: Devise::email_regexp

  def perform
    return false unless valid?
    Notify.message("contact_form #{email} @ #{Time.zone.now}", text: text)
    true
  end
end
