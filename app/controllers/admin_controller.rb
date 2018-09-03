class AdminController < ApplicationController
  before_action :_check_admin

  def dashboard; end

  def notify_user
    @notify_user_form = NotifyUserForm.new
  end

  def submit_notify_user
    @notify_user_form = NotifyUserForm.new params.require(:notify_user_form).permit(:subject, :message)
    if @notify_user_form.perform
      redirect_to admin_dashboard_path, notice: t('successfully')
    else
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
