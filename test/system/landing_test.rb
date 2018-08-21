require 'application_system_test_case'

class LandingTest < ApplicationSystemTestCase
  test 'create new user and move and matching after confirmation' do
    from_group = create :group
    to_location = create :location, city: from_group.location.city
    to_group = create :group, location: to_location, age: from_group.age
    # matching oposite move
    reverse_move = create :move, from_group: to_group, to_groups: [from_group]
    email = 'my@email.com'

    visit root_url
    # select from_group.location.city.name, from: t('activemodel.attributes.landing_signup.current_city')
    select2_ajax from_group.location.name_with_address, text: t('activemodel.attributes.landing_signup.current_location')
    select from_group.age_with_title, from: t('activemodel.attributes.landing_signup.from_group_age')
    select2_ajax to_location.name_with_address, text: t('activemodel.attributes.landing_signup.to_location')
    fill_in t('activemodel.attributes.landing_signup.email'), with: email
    click_on t'continue'
    fill_in t('activemodel.attributes.landing_signup.password'), with: '1234567'
    assert_difference 'Move.count', 1 do
      assert_difference 'User.count', 1 do
        assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
          click_on t('activemodel.attributes.landing_signup.submit')
        end
      end
    end

    user = User.find_by email: email
    assert_kind_of User, user
    refute user.confirmed?
    move = user.moves.last
    assert_equal from_group, move.from_group
    assert_equal [to_group], move.to_groups

    assert_selector 'a', text: user.email_username
    refute_selector 'a', text: t('sign_in')
    click_on user.email_username
    click_on t('sign_out')
    assert_selector 'a', text: t('sign_in')

    registration_email = give_me_last_mail_and_clear_mails
    assert_equal [email], registration_email.to
    confirmation_link = registration_email.html_part.decoded.match(
      /(http:.*?confirmation.*?)"/
    )[1]
    user = User.find_by email: email
    refute user.confirmed?

    assert_difference 'Chat.count', 1 do
      assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
        visit confirmation_link
      end
    end

    assert user.reload.confirmed?
    assert_selector 'a', text: user.email_username
    refute_selector 'a', text: t('register')

    new_match_email = give_me_last_mail_and_clear_mails
    assert_equal [reverse_move.user.email], new_match_email.to
    assert_equal "#{t('new_match')} #{reverse_move.from_group.location.name}", new_match_email.subject
  end
end
