class MyDeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record_id, token, opts = {})
    record = User.find record_id
    super record, token, opts
  end

  def reset_password_instructions(record_id, token, opts = {})
    record = User.find record_id
    super record, token, opts
  end

  def unlock_instructions(record_id, token, opts = {})
    record = User.find record_id
    super record, token, opts
  end

  def email_changed(record_id, opts = {})
    record = User.find record_id
    super record, opts
  end

  def password_change(record_id, opts = {})
    record = User.find record_id
    super record, opts
  end
end
