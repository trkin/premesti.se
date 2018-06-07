module MailerHelper
  def pre_header(message)
    content_for :pre_header, message
  end
end
