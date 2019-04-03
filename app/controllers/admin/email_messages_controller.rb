class Admin::EmailMessagesController < AdminController
  def index
    @email_messages = EmailMessage.order(created_at: :desc).page params[:page]
  end
end
