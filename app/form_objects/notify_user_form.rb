class NotifyUserForm
  include ActiveModel::Model
  attr_accessor :subject, :message, :user_id, :tag, :limit

  validates :subject, :message, presence: true

  def perform
    return Error.new(errors.full_messages.to_sentence) unless valid?

    return Error.new('Tag is required when sending to all') if user_id.blank? && tag.blank?

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
    if user_id.present?
      _send_to_particular_user
    else
      _send_to_all_users
    end
  end

  def _send_to_particular_user
    [User.find(user_id)]
  end

  def _send_to_all_users
    res = User.query_as(:user)
              .where('user.confirmed_at IS NOT NULL')
              .where("NOT (user)-[:RECEIVED]-(:EmailMessage { tag: '#{tag}'})")
              .pluck(:user)
    res = res.first(limit.to_i) if limit.present?
    res
  end
end
