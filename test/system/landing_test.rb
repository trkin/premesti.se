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
    select2_ajax from_group.location.name_with_address, text: nil, selector: '#select2-current_location-container'
    select from_group.age_with_title, from: t('activemodel.attributes.landing_signup.from_group_age')
    select2_ajax to_location.name_with_address, text: nil, selector: '#select2-to_location-container'
    fill_in t('activemodel.attributes.landing_signup.email'), with: email
    check LandingSignup.human_attribute_name(:visible_email_address)
    fill_in t('activemodel.attributes.landing_signup.password'), with: '1234567'
    check LandingSignup.human_attribute_name(:subscribe_to_new_match)
    check LandingSignup.human_attribute_name(:subscribe_to_news_mailing_list)
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
    assert user.visible_email_address
    assert user.subscribe_to_new_match
    assert user.subscribe_to_news_mailing_list

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
      assert_performed_jobs 2, only: ActionMailer::DeliveryJob do
        visit confirmation_link
        assert user.reload.confirmed?
        assert_selector 'a', text: user.email_username
        refute_selector 'a', text: t('register')
      end
    end

    # we send 2 emails, to both parties
    new_match_for_him, new_match_for_me = give_me_all_mail_and_clear_mails
    assert_equal [user.email], new_match_for_me.to
    assert_equal [reverse_move.user.email], new_match_for_him.to
    assert_match "#{t('new_match')} #{from_group.location.name}", new_match_for_me.subject
    assert_match "#{t('new_match')} #{reverse_move.from_group.location.name}", new_match_for_him.subject
  end

  test 'sign up on move page' do
    email = 'my@email.com'
    move = create :move
    visit my_move_path move, move.group_age_and_locations

    select2_ajax move.from_group.location.name_with_address, text: t('activemodel.attributes.landing_signup.current_location')
    fill_in t('activemodel.attributes.landing_signup.email'), with: email
    fill_in t('activemodel.attributes.landing_signup.password'), with: '1234567'
    check LandingSignup.human_attribute_name(:subscribe_to_new_match)

    assert_difference 'User.count', 1 do
      click_on t('activemodel.attributes.landing_signup.submit')
    end
    user = User.find_by email: email
    assert_kind_of User, user
  end
end
