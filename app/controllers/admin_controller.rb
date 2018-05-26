class AdminController < ApplicationController
  before_action :_check_admin

  def dashboard; end

  def reported_messages
    @reported_messages = Message.reported
  end

  def _check_admin
    redirect_to(root_path) unless current_user.admin?
  end
end
