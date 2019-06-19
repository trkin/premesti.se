class Admin::UsersController < AdminController
  before_action :_set_user, except: %i[index]

  def show
    if @user.auth.present?
      auth = JSON.parse @user.auth
      @image = auth['info']['image']
    end
    @chats_active = @user.moves.chats.active.page(params[:page]).per(5)
    @chats_archived = @user.moves.chats.archived.page(params[:page]).per(5)
    @email_messages = @user.email_messages.page(params[:page]).per(5)
  rescue JSON::ParserError => e
    flash.now[:alert] = e.message
  end

  def index
    @users = User
             .as(:u)
             .with_associations(moves: { from_group: [:location], to_groups: [:location] })
             .order('u.created_at DESC')
             .page params[:page]
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

  def _set_user
    @user = User.find params[:id]
  end
end
