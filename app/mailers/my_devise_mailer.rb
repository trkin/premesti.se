class MyDeviseMailer < Devise::Mailer
  default from: Rails.application.secrets.mailer_sender
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  # TODO: when I use our layout
  # layout 'mailer'
  # than there is a error
  # NameError: undefined local variable or method `root_url'
  # probably need to
  #  config.include Rails.application.routes.url_helpers

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
