module MailerHelper
  def pre_header(message)
    content_for :pre_header, message
  end

  def strip_with_dots(message)
    return '' unless message.present?
    max_visible_chars = 12
    if message.length > max_visible_chars
      "#{message[0..11]}..."
    elsif message.length > 3
      "#{message[0..-4]}..."
    else
      message
    end
  end
end
