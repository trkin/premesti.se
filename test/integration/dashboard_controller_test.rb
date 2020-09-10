require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test 'unauthorized' do
    get dashboard_path
    assert_response :redirect
  end

  test 'see link to edit move' do
    user = create :user
    move = create :move, user: user
    sign_in user
    get dashboard_path
    assert_response :success
    assert_select 'a[href=?]', move_path(move)
  end

  test 'buy_me_a_coffee redirect to chat if shared_chat and chat_id present' do
    user = create :user
    chat = create :chat
    user.shared_chats << chat
    sign_in user
    get buy_me_a_coffee_path(chat_id: chat.id)
    assert_redirected_to chat_path(chat)
  end

  test 'shared_callback' do
    user = create :user
    chat = create :chat
    sign_in user
    get shared_callback_path(model_id: "chat_id:#{chat.id}")
    assert_equal response.body, 'adding chat to shared_chats'

    user.shared_chats << chat
    get shared_callback_path(model_id: "chat_id:#{chat.id}")
    assert_equal response.body, 'user already shared this chat'

    get shared_callback_path(model_id: "")
    assert_equal response.body, "model in params[:model_id]= is not correct"
  end
end
