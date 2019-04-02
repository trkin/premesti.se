class AdminController < ApplicationController
  before_action :_check_admin

  def dashboard; end

  def notify_user
    @notify_user_form = NotifyUserForm.new(
      limit: 1
    )
  end

  def submit_notify_user
    @notify_user_form = NotifyUserForm.new params.require(:notify_user_form).permit(:subject, :message, :user_id, :tag, :limit)
    result = @notify_user_form.perform
    if result.success?
      redirect_to admin_notify_user_path, notice: result.message
    else
      flash.now[:alert] = result.message
      render :notify_user
    end
  end

  def reported_messages
    @reported_messages = Message.reported
  end

  def _check_admin
    redirect_to(root_path) unless current_user.admin?
  end
end
