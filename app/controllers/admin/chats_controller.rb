class Admin::ChatsController < AdminController
  def index
    @chats = Chat.all.order(:created_at)
    if params[:status] == 'active'
      @chats = @chats.active
    elsif params[:status] == 'archived'
      @chats = @chats.archived
    end
  end
end
