class NotifyUserForm
  include ActiveModel::Model
  attr_accessor :subject, :message, :user_id, :tag, :limit

  validates :subject, :message, presence: true

  def perform
    return Error.new(errors.full_messages.to_sentence) unless valid?

    unconfirmed = []
    non_active = []
    sent = []
    send_to_users.each do |user|
      unless user.confirmed?
        unconfirmed.append user
        next
      end
      unless user.active?
        non_active.append user
        next
      end
      sent.append user
      UserMailer.notification(user.id, subject, message, tag).deliver_later
    end
    message = "Send to #{sent.count} users (#{sent.first(5).map(&:email).to_sentence})"
    message += "Unconfirmed #{unconfirmed.size} (#{unconfirmed.first(5).map(&:email).to_sentence})" if unconfirmed.present?
    message += "Nonactive #{non_active.size} (#{non_active.first(5).map(&:email).to_sentence})" if non_active.present?
    Result.new message
  end

  def confirmed_users
    User.confirmed
  end

  def recent_tags
    EmailMessage.all.map(&:tag).uniq.to_sentence
  end

  def send_to_users
    result = if user_id.present?
               [User.find(user_id)]
             else
               confirmed_users
             end
    if tag.present?
      # TODO: move this to query
      result = result.reject do |user|
        user.email_messages.where(tag: tag).present?
      end
    end
    result = result.first(limit.to_i) if limit.present? && user_id.blank?
    result
  end
end
