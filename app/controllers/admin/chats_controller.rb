class Admin::ChatsController < AdminController
  def index
    @chats = Chat.all.order(:created_at)
  end
end
