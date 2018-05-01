require "application_system_test_case"
require 'helpers/system_login_helpers'

class UsersTest < ApplicationSystemTestCase
  include SystemLoginHelpers

  test 'register new user' do
    manual_register 'new@email.com', 'some_password'

    assert_text t("devise.registrations.signed_up")
  end

  test 'register user already exists' do
    email = 'my@email.com'
    create :user, email: email
    manual_register email, 'some_password'
    assert_text t("neo4j.attributes.user.email") + " " + t("neo4j.errors.messages.taken")
  end

  test 'register already exists, email upercased' do
    create :user, email: 'my@email.com'
    manual_register 'mY@email.com', 'some_password'
    assert_text t("neo4j.attributes.user.email") + " " + t("neo4j.errors.messages.taken")
  end

  test 'register already exists, email not striped' do
    create :user, email: 'my@email.com'
    manual_register ' my@email.com ', 'some_password'
    assert_text t("neo4j.attributes.user.email") + " " + t("neo4j.errors.messages.taken")
  end

  test 'login' do
    email = 'my@email.com'
    password = '12345678'
    create :user, email: email, password: password
    manual_login email, password
    assert_selector '#userDropdown', text: 'my@email.com'
  end

  test 'login, email upercased' do
    password = '12345678'
    create :user, email: 'my@email.com', password: password
    manual_login 'my@eMail.com', password
    assert_selector '#userDropdown', text: 'my@email.com'
  end

  test 'login, email not striped' do
    password = '12345678'
    create :user, email: 'my@email.com', password: password
    manual_login ' my@email.com ', password
    assert_selector '#userDropdown', text: 'my@email.com'
  end

  test 'forgot password' do
    email = 'my@email.com'
    create :user, email: email
    visit new_user_password_path
    fill_in t("neo4j.attributes.user.email"), with: email
    click_on t("my_devise.send_me_reset_password_instructions")

    assert_text t("devise.passwords.send_instructions")
  end

  test 'resend confirmation instructions' do
    email = 'my@email.com'
    create :user, email: email, confirmed_at: nil
    visit new_user_confirmation_path
    fill_in t("neo4j.attributes.user.email"), with: email
    click_on t("send")

    assert_text t("devise.confirmations.send_instructions")
  end

  test 'resend unlock instructions' do
    return unless User.devise_modules.include?(:lockable) && User.unlock_strategy_enabled?(:email)
    email = 'my@email.com'
    create :user, email: email, locked_at: Time.zone.now
    visit new_user_unlock_path
    fill_in t("neo4j.attributes.user.email"), with: email
    click_on t("my_devise.resend_unlock_instructions")

    assert_text t("devise.unlocks.send_instructions")
  end
end
