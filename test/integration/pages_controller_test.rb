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
        assert_difference 'ActionMailer::Base.deliveries.size', 1 do
          post landing_signup_path, params: { landing_signup: params }
        end
      end
    end
    assert_redirected_to dashboard_path
    mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), mail.html_part.decoded
  end

  test 'landing signup missing params render errors' do
    params = { email: '' }
    post landing_signup_path, params: { landing_signup: params }
    assert_response :success
    assert_select '#alert-debug', /#{t('errors.messages.blank')}/
  end

  test 'landing signup already existing email and valid password' do
    email = 'my@email.com'
    password = '1234567'
    create :user, email: email, password: password
    group = create :group
    params = {
      email: email,
      password: password,
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group_age: group.age,
    }
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_difference 'ActionMailer::Base.deliveries.size', 1 do
          post landing_signup_path, params: { landing_signup: params }
        end
      end
    end
    assert_redirected_to dashboard_path
    mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service'), mail.html_part.decoded
  end

  test 'landing signup with match but no chat since user not confirmed' do
    age = 2
    group_a = create :group, name: 'A', age: age
    group_b = create :group, name: 'B', age: age
    create :move, from_group: group_a, to_groups: [group_b]

    email = 'new@user.com'
    params = {
      email: email,
      password: '1234567',
      current_city: group_b.location.city.id,
      current_location: group_b.location.id,
      from_group_age: group_b.age,
      to_location: group_a.location.id,
    }
    assert_difference 'User.count', 1 do
      assert_difference 'Move.count', 1 do
        assert_difference 'Chat.count', 0 do
          assert_difference 'ActionMailer::Base.deliveries.size', 1 do
            post landing_signup_path, params: { landing_signup: params }
          end
        end
      end
    end
    assert_redirected_to dashboard_path
  end

  test 'landing signup with correct password and chat is creted' do
    age = 2
    group_a = create :group, name: 'A', age: age
    group_b = create :group, name: 'B', age: age
    create :move, from_group: group_a, to_groups: [group_b]
    password = '12345678'
    user = create :user, password: password
    params = {
      email: user.email,
      password: user.password,
      current_city: group_b.location.city.id,
      current_location: group_b.location.id,
      from_group_age: group_b.age,
      to_location: group_a.location.id,
    }
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_difference 'Chat.count', 1 do
          assert_difference 'ActionMailer::Base.deliveries.size', 2 do
            post landing_signup_path, params: { landing_signup: params }
          end
        end
      end
    end
    assert_redirected_to dashboard_path
    chat_mail, registration_mail = ActionMailer::Base.deliveries
    assert_match t('user_mailer.landing_signup.description_of_service'), registration_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), chat_mail.html_part.decoded
  end
end
