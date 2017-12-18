require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  def register(email)
    visit new_user_registration_path
    fill_in t("neo4j.attributes.user.email"), with: email
    fill_in t("neo4j.attributes.user.password"), with: 'password'
    fill_in t("neo4j.attributes.user.password_confirmation"), with: 'password'

    click_on t("register")
  end

  def login(email, password)
    visit new_user_session_path
    fill_in t("neo4j.attributes.user.email"), with: email
    fill_in t("neo4j.attributes.user.password"), with: password

    click_on t("sign_in")
  end

  test 'register new user' do
    register 'new@email.com'

    assert_text t("devise.registrations.signed_up")
  end

  test 'register user already exists' do
    email = 'my@email.com'
    create :user, email: email
    register email
    assert_text t("neo4j.attributes.user.email") + " " + t("neo4j.errors.messages.taken")
  end

  test 'register already exists, email upercased' do
    create :user, email: 'my@email.com'
    register 'mY@email.com'
    assert_text t("neo4j.attributes.user.email") + " " + t("neo4j.errors.messages.taken")
  end

  test 'register already exists, email not striped' do
    create :user, email: 'my@email.com'
    register ' my@email.com '
    assert_text t("neo4j.attributes.user.email") + " " + t("neo4j.errors.messages.taken")
  end

  test 'login' do
    email = 'my@email.com'
    password = '12345678'
    create :user, email: email, password: password
    login email, password
    assert_text t("sign_out")
  end

  test 'login, email upercased' do
    password = '12345678'
    create :user, email: 'my@email.com', password: password
    login 'my@eMail.com', password
    assert_text t("sign_out")
  end

  test 'login, email not striped' do
    password = '12345678'
    create :user, email: 'my@email.com', password: password
    login ' my@email.com ', password
    assert_text t("sign_out")
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
    click_on t("my_devise.resend_confirmation_instructions")

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
