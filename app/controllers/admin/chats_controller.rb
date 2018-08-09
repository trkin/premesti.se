class Admin::ChatsController < AdminController
  def index
    @chats = Chat.all
  end
end
