class Admin::ChatsController < AdminController
  def index
    @chats = Chat.all.order(:created_at)
    if params[:status] == 'active'
      @chats = @chats.active
    elsif params[:status] == 'archived'
      @chats = @chats.archived
    end
    @chats = @chats.where(archived_reason: params[:archived_reason]) if params[:archived_reason].present?
    @chats = @chats.page params[:page]
  end

  def featured
    chat = Chat.find params[:id]
    chat.featured_on_home_page = true
    chat.save!
    redirect_to admin_chats_path
  end
end
