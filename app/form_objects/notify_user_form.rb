class NotifyUserForm
  include ActiveModel::Model
  attr_accessor :subject, :message
  validates :subject, :message, presence: true

  def perform
    return false unless valid?
    User.confirmed.each do |user|
      UserMailer.notification(user.id, subject, message).deliver_later
    end
    true
  end
end
