require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/'
    assert_response :success
    assert_select 'label', t('activemodel.attributes.landing_signup.current_location')
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
    assert_select 'h1', t('my_moves')

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
    }
    assert_difference 'User.count', 1 do
      assert_difference 'Move.count', 1 do
        assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
          post my_move_path(move, move.group_age_and_locations), params: { landing_signup: params }
        end
      end
    end
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_select 'h1', t('my_moves')

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
    }
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
          post my_move_path(move, move.group_age_and_locations), params: { landing_signup: params }
        end
      end
    end
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_select 'h1', t('my_moves')

    chat_mail, move_mail = all_mails
    assert_match t('user_mailer.landing_signup.description_of_service'), move_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), chat_mail.html_part.decoded
  end
end
