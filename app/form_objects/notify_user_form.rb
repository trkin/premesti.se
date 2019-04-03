class NotifyUserForm
  include ActiveModel::Model
  attr_accessor :subject, :message, :user_id, :tag, :limit

  validates :subject, :message, presence: true
  validate :_tag_is_required

  def _tag_is_required
    return true if user_id.present? || tag.present?

    errors.add(:tag, 'is required when sending to all')
    false
  end

  def perform
    return Error.new(errors.full_messages.to_sentence) unless valid?

    send_to_users.each do |user|
      UserMailer.notification(user.id, subject, message, tag).deliver_later(Rails.env.production? ? {wait: 3.minutes} : {})
    end
    message = "Send to #{send_to_users.count} users (#{send_to_users.first(5).map(&:email).to_sentence})"
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
              .order('user.created_at ASC')
              .where('user.confirmed_at IS NOT NULL')
              .where('user.status = ?', User.statuses[:active])
              .where("NOT (user)-[:RECEIVED]-(:EmailMessage { tag: '#{tag}'})")
              .pluck(:user)
    res = res.first(limit.to_i) if limit.present?
    res
  end
end
