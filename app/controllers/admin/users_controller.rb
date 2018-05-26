class Admin::UsersController < AdminController
  def show
    _set_user
  end

  def index
    @users = User.all
  end

  def _set_user
    @user = User.find params[:id]
  end
end
