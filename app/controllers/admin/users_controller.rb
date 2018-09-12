class Admin::UsersController < AdminController
  before_action :_set_user, only: %i[show update]
  def show; end

  def index
    @users = User
             .as(:u)
             .with_associations(moves: { from_group: [:location], to_groups: [:location] })
             .order('u.last_sign_in_at DESC')
  end

  def update
    @user.status = params[:user][:status]
    @user.save!
    redirect_to admin_user_path(@user)
  end

  def _set_user
    @user = User.find params[:id]
  end
end
