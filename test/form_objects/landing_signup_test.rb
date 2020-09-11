require 'test_helper'
require 'sidekiq/testing'

class LandingSinupTest < ActiveSupport::TestCase
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
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 1 do
      assert_difference 'Move.count', 1 do
        assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
          landing_signup.perform
        end
      end
    end
    move_mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), move_mail.html_part.decoded
  end

  test 'landing signup already existing email and valid password' do
    email = 'my@email.com'
    password = '1234567'
    user = create :user, email: email, password: password
    group = create :group
    params = {
      email: email,
      password: password,
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group_age: group.age,
      subscribe_to_new_match: '1',
    }
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
          landing_signup.perform
        end
      end
    end
    assert_equal user, landing_signup.user
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
      subscribe_to_new_match: '1',
      to_location: group_a.location.id,
    }
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 1 do
      assert_difference 'Move.count', 1 do
        assert_difference 'Chat.count', 0 do
          assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
            landing_signup.perform
          end
        end
      end
    end
    move_mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), move_mail.html_part.decoded
  end

  test 'landing signup with correct password and chat is created' do
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
      subscribe_to_new_match: '1',
      to_location: group_a.location.id,
    }
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_difference 'Chat.count', 1 do
          assert_performed_jobs 4 do
            perform_enqueued_jobs do
              landing_signup.perform
            end
          end
        end
      end
    end
    chat_mail, another_chat_mail, move_mail, should_be_nil = give_me_all_mail_and_clear_mails
    assert_nil should_be_nil
    assert_match t('user_mailer.landing_signup.description_of_service'), move_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), chat_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), another_chat_mail.html_part.decoded
  end

  test 'landing already logged in create move' do
    age = 2
    group_a = create :group, name: 'A', age: age
    group_b = create :group, name: 'B', age: age
    create :move, from_group: group_a, to_groups: [group_b]
    user = create :user
    params = {
      current_city: group_b.location.city.id,
      current_location: group_b.location.id,
      from_group_age: group_b.age,
      to_location: group_a.location.id,
      current_user: user,
    }
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_difference 'Chat.count', 1 do
          # 1 registration mail, 2 notification mails and
          # CreateChatAndSendNotificationsJob
          assert_performed_jobs 4 do
            perform_enqueued_jobs do
              landing_signup.perform
            end
          end
        end
      end
    end
    chat_mail, other_user_chat_mail, move_mail = give_me_all_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service'), move_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), chat_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), other_user_chat_mail.html_part.decoded
  end

  test 'landing already logged unconfirmed create move' do
    age = 2
    group_a = create :group, name: 'A', age: age
    group_b = create :group, name: 'B', age: age
    create :move, from_group: group_a, to_groups: [group_b]
    user = create :unconfirmed_user
    params = {
      current_city: group_b.location.city.id,
      current_location: group_b.location.id,
      from_group_age: group_b.age,
      to_location: group_a.location.id,
      current_user: user,
    }
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 1 do
        assert_difference 'Chat.count', 0 do
          assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
            landing_signup.perform
          end
        end
      end
    end
    move_mail = give_me_last_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), move_mail.html_part.decoded
  end

  test 'landing already logged in create to_group if move from_group exists' do
    age = 2
    group_a = create :group, name: 'A', age: age
    group_b = create :group, name: 'B', age: age
    create :move, from_group: group_a, to_groups: [group_b]
    user = create :user
    create :move, from_group: group_b, user: user
    params = {
      current_city: group_b.location.city.id,
      current_location: group_b.location.id,
      from_group_age: group_b.age,
      to_location: group_a.location.id,
      current_user: user,
    }
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 0 do
        assert_difference 'Chat.count', 1 do
          # 1 registration mail, 2 notification mails and
          # CreateChatAndSendNotificationsJob
          assert_performed_jobs 4 do
            perform_enqueued_jobs do
              landing_signup.perform
            end
          end
        end
      end
    end
    chat_mail, other_user_chat_mail, move_mail = give_me_all_mail_and_clear_mails
    assert_match t('user_mailer.landing_signup.description_of_service'), move_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), chat_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), other_user_chat_mail.html_part.decoded
  end

  test 'landing already logged in, already have this move' do
    age = 2
    group_a = create :group, name: 'A', age: age
    group_b = create :group, name: 'B', age: age
    create :move, from_group: group_a, to_groups: [group_b]
    user = create :user
    create :move, from_group: group_b, to_groups: [group_a], user: user
    params = {
      current_city: group_b.location.city.id,
      current_location: group_b.location.id,
      from_group_age: group_b.age,
      to_location: group_a.location.id,
      current_user: user,
    }
    landing_signup = LandingSignup.new params
    assert_difference 'User.count', 0 do
      assert_difference 'Move.count', 0 do
        assert_difference 'Chat.count', 0 do
          assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
            landing_signup.perform
          end
        end
      end
    end
    move_mail = give_me_all_mail_and_clear_mails.first
    assert_match t('user_mailer.landing_signup.description_of_service'), move_mail.html_part.decoded
  end
end
