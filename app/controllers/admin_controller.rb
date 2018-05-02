class AdminController < ApplicationController
  before_action :check_admin

  def dashboard; end

  def users
    @users = User.all
  end

  def check_admin
    redirect_to(root_path) unless current_user.admin?
  end
end
