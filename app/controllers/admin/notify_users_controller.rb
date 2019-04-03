class Admin::NotifyUsersController < AdminController
  def index
    @notify_user_form = NotifyUserForm.new(
      limit: 1,
      tag: EmailMessage.last_tag,
    )
  end

  def create
    @notify_user_form = NotifyUserForm.new params.require(:notify_user_form).permit(:subject, :message, :user_id, :tag, :limit)
    result = @notify_user_form.perform
    if result.success?
      redirect_to admin_notify_users_path, notice: result.message
    else
      flash.now[:alert] = result.message
      render :index
    end
  end
end
