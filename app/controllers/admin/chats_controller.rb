class Admin::ChatsController < AdminController
  def index
    @chats = Chat.all.order(:created_at)
    if params[:status] == 'active'
      @chats = @chats.active
    elsif params[:status] == 'archived'
      @chats = @chats.archived
    end
    @chats = @chats.where(archived_reason: params[:archived_reason]) if params[:archived_reason].present?
  end
end
