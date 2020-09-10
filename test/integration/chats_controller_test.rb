require 'test_helper'

class ChatsControllerTest < ActionDispatch::IntegrationTest
  def create_chat_and_sign_in
    move = create :move
    second_move = create :move
    third_move = create :move
    chat = Chat.create_for_moves [move, second_move, third_move]
    move.user.shared_chats << chat
    sign_in move.user
    chat
  end

  test 'redirect if not shared' do
    chat = create_chat_and_sign_in
    user = chat.moves.select { |m| m.user.shared_chats.present? }.last.user
    refute_empty user.shared_chats
    user.shared_chats.delete chat
    assert_empty user.shared_chats
    refute user.can_see_chat(chat)
    get chat_path(chat)
    assert_redirected_to buy_me_a_coffee_path(chat_id: chat.id)
  end

  test 'create message and send notification' do
    chat = create_chat_and_sign_in
    assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
      post create_message_chat_path(chat), params: { message: { text: 'first_message' } }, xhr: true
      give_me_all_mail_and_clear_mails
    end
    assert response.body.include? t_crud('success_create', Message)
  end

  test 'ignore unsubscribed' do
    chat = create_chat_and_sign_in
    user = chat.moves.to_a.second.user
    user.subscribe_to_new_match = false
    user.save!
    assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
      post create_message_chat_path(chat), params: { message: { text: 'first_message' } }, xhr: true
    end
    assert response.body.include? t_crud('success_create', Message)
    _chat_mail1, chat_mail2 = give_me_all_mail_and_clear_mails
    assert_nil chat_mail2
  end

  test 'empty message show error' do
    chat = create_chat_and_sign_in
    post create_message_chat_path(chat), params: { message: { text: '' } }, xhr: true
    assert response.body.include? ActionController::Base.helpers.j(t('errors.messages.blank'))
  end
end
