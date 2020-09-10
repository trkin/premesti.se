require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/'
    assert_response :success
    assert_select 'a', t('sign_in')
  end

  test 'get public_move' do
    move = create :move
    get public_move_path(move, move.group_age_and_locations)
    assert_response :success
  end

  test 'get public_chat' do
    chat = create :chat
    get public_chat_path(chat, chat.name_with_arrows)
    assert_response :success
  end

  test 'landing signup success' do
    email = 'my@email.com'
    group = create :group
    params = {
      email: email,
      password: '1234567',
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group_age: group.age,
      subscribe_to_new_match: '1',
    }
    assert_difference 'User.count', 1 do
      assert_difference 'Move.count', 1 do
        assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
          post landing_signup_path, params: { landing_signup: params }
        end
      end
    end
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_notice_message t('activemodel.models.landing_signup.success_notice') + ' ' + t('devise.registrations.signed_up_but_unconfirmed')

    move_mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), move_mail.html_part.decoded
  end

  test 'landing signup missing params render errors' do
    params = { email: '' }
    post landing_signup_path, params: { landing_signup: params }
    assert_response :success
    assert_select '#alert-debug', /#{t('errors.messages.blank')}/
  end

  test 'my move signup success' do
    move = create :move
    email = 'my@email.com'
    group = create :group
    params = {
      email: email,
      password: '1234567',
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group_age: group.age,
      subscribe_to_new_match: '1',
    }
    assert_difference 'User.count', 1 do
      assert_difference 'Move.count', 1 do
        assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
          post public_move_path(move, move.group_age_and_locations), params: { landing_signup: params }
        end
      end
    end
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_notice_message t('activemodel.models.landing_signup.success_notice') + ' ' + t('devise.registrations.signed_up_but_unconfirmed')

    move_mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), move_mail.html_part.decoded
  end

  test 'my move already signed in' do
    move = create :move
    to_group = create :group, age: move.from_group.age
    move.to_groups << to_group

    user = create :user
    sign_in user

    params = {
      current_city: to_group.location.city.id,
      current_location: to_group.location.id,
      from_group_age: move.from_group.age,
      to_location: move.from_group.location.id,
      subscribe_to_new_match: '1',
    }
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_performed_jobs 3, only: ActionMailer::DeliveryJob do
          post public_move_path(move, move.group_age_and_locations), params: { landing_signup: params }
        end
      end
    end
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_notice_message t('activemodel.models.landing_signup.success_notice')

    chat_mail, another_chat_mail, move_mail = give_me_all_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service'), move_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), chat_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), another_chat_mail.html_part.decoded
  end
end
