require 'test_helper'

class ChatsControllerTest < ActionDispatch::IntegrationTest
  def create_chat_and_sign_in
    move = create :move
    second_move = create :move
    third_move = create :move
    chat = Chat.create_for_moves [move, second_move, third_move]
    sign_in move.user
    chat
  end

  test 'create message and send notification' do
    chat = create_chat_and_sign_in
    assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
      post create_message_chat_path(chat), params: { message: { text: 'first_message' } }
    end
    follow_redirect!
    assert_select_notice_message t_crud('success_create', Message)
    assert response.body.include? 'first_message'
  end

  test 'empty message show error' do
    chat = create_chat_and_sign_in
    post create_message_chat_path(chat), params: { message: { text: '' } }
    assert_select_field_error t('errors.messages.blank')
  end
end
