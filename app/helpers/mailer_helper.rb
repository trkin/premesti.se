module MailerHelper
  def subject_line(message)
    content_for :subject_line, message
  end
end
