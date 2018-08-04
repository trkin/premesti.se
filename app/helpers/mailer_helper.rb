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

  # https://stackoverflow.com/questions/11078264/how-to-get-rid-of-show-trimmed-content-in-gmail-html-emails
  def prevent_trim
    "<span class='hide-to-up pre-header'>#{Time.zone.now}</span>".html_safe
  end
end
