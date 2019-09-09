class Admin::UsersController < AdminController
  before_action :_set_user, except: %i[index]

  def show
    @chats_active = @user.moves.chats.active.page(params[:page]).per(5)
    @chats_archived = @user.moves.chats.archived.page(params[:page]).per(5)
    @email_messages = @user.email_messages.page(params[:page]).per(5)
  end

  def index
    @datatable = UsersDatatable.new view_context
  end

  def search
    render json: UsersDatatable.new(view_context)
  end

  def update
    @user.status = params[:user][:status]
    @user.save!
    redirect_to admin_user_path(@user)
  end

  def destroy_move
    move = @user.moves.find params[:move_id]
    move.destroy_and_archive_chats 'added_move_by_mistake'
    redirect_to admin_user_path(@user)
  end

  def destroy
    Notify.message "destroy_user #{@user.email}", any_reason: params[:any_reason], my_data: @user.my_data
    @user.destroy_moves_and_messages params[:any_reason].presence
    @user.destroy
    redirect_to admin_users_path
  end

  def _set_user
    @user = User.find params[:id]
  end
end
