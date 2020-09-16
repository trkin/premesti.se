require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  def assert_user_logged_in_with_email(email)
    assert_selector 'a#userDropdown', text: email.split('@').first
  end

  def manual_register(email, password)
    visit new_user_registration_path
    fill_in t('neo4j.attributes.user.email'), with: email
    fill_in t('neo4j.attributes.user.password'), with: password
    fill_in t('neo4j.attributes.user.password_confirmation'), with: password

    click_on t('register')
  end

  def manual_login(email, password)
    visit new_user_session_path
    fill_in t('neo4j.attributes.user.email'), with: email
    fill_in t('neo4j.attributes.user.password'), with: password

    click_on t('sign_in')
  end

  test 'register new user' do
    manual_register 'new@email.com', 'some_password'

    assert_text t('devise.registrations.signed_up')
    user = User.find_by email: 'new@email.com'
    assert_equal user.locale, 'en'
  end

  test 'register user already exists' do
    email = 'my@email.com'
    create :user, email: email
    manual_register email, 'some_password'
    assert_text t('neo4j.attributes.user.email') + ' ' + t('neo4j.errors.messages.taken')
  end

  test 'register already exists, email upercased' do
    create :user, email: 'my@email.com'
    manual_register 'mY@email.com', 'some_password'
    assert_text t('neo4j.attributes.user.email') + ' ' + t('neo4j.errors.messages.taken')
  end

  test 'register already exists, email not striped' do
    create :user, email: 'my@email.com'
    manual_register ' my@email.com ', 'some_password'
    assert_text t('neo4j.attributes.user.email') + ' ' + t('neo4j.errors.messages.taken')
  end

  test 'login' do
    email = 'my@email.com'
    password = '12345678'
    create :user, email: email, password: password
    manual_login email, password
    assert_selector '#userDropdown', text: 'my'
  end

  test 'login, email upercased' do
    password = '12345678'
    create :user, email: 'my@email.com', password: password
    manual_login 'my@eMail.com', password
    assert_selector '#userDropdown', text: 'my'
  end

  test 'login, email not striped' do
    password = '12345678'
    create :user, email: 'my@email.com', password: password
    manual_login ' my@email.com ', password
    assert_selector '#userDropdown', text: 'my'
  end

  test 'forgot password' do
    email = 'my@email.com'
    user = create :user, email: email
    visit new_user_password_path
    fill_in t('neo4j.attributes.user.email'), with: email
    perform_enqueued_jobs only: ActionMailer::DeliveryJob do
      click_on t('my_devise.send_me_reset_password_instructions')
    end

    assert_text t('devise.passwords.send_instructions')
    mail = give_me_last_mail_and_clear_mails
    link = mail.html_part.to_s.match("(http://.*)\">#{t('change_password')}")[1]
    visit link
    fill_in t('my_devise.new_password'), with: 'new_password'
    fill_in t('neo4j.attributes.user.password_confirmation'), with: 'new_password'
    click_on t('update')

    user.reload
    assert user.valid_password? 'new_password'
  end

  test 'resend confirmation instructions' do
    email = 'my@email.com'
    create :user, email: email, confirmed_at: nil
    visit new_user_confirmation_path
    fill_in t('neo4j.attributes.user.email'), with: email
    click_on t('send')

    assert_text t('devise.confirmations.send_instructions')
  end

  test 'resend unlock instructions' do
    return unless User.devise_modules.include?(:lockable) && User.unlock_strategy_enabled?(:email)

    email = 'my@email.com'
    create :user, email: email, locked_at: Time.zone.now
    visit new_user_unlock_path
    fill_in t('neo4j.attributes.user.email'), with: email
    click_on t('my_devise.resend_unlock_instructions')

    assert_text t('devise.unlocks.send_instructions')
  end

  test 'change password' do
    user = create :user, password: 'old_password'
    sign_in user
    visit edit_user_registration_path
    fill_in t('neo4j.attributes.user.current_password'), with: 'old_password'
    fill_in t('neo4j.attributes.user.password'), with: 'new_password'
    fill_in t('neo4j.attributes.user.password_confirmation'), with: 'new_password'
    click_on t('update')

    assert_text t('devise.registrations.updated')

    user.reload
    assert user.valid_password? 'new_password'
  end

  test 'change locale' do
    user = create :user
    sign_in user
    visit my_settings_path
    select 'Премести се (ћирилица)'
    click_on t('update')
    user.reload
    assert_equal user.locale, 'sr'
  end

  test 'register new user in non default url' do
    email = 'new@email.com'
    password = 'some_password'
    visit new_user_registration_url host: Constant::DOMAINS[:development][:sr]
    fill_in t('neo4j.attributes.user.email', locale: :sr), with: email
    fill_in t('neo4j.attributes.user.password', locale: :sr), with: password
    fill_in t('neo4j.attributes.user.password_confirmation', locale: :sr), with: password

    click_on t('register', locale: :sr)

    assert_text t('devise.registrations.signed_up', locale: :sr)
    user = User.find_by email: email
    assert_equal user.locale, 'sr'
  end

  test 'canceling user removes moves and messages' do
    user = create :user
    move = create :move, user: user
    chat = Chat.create_for_moves [move, move]
    message = create :message, chat: chat, user: user, text: 'blabla'

    sign_in user
    visit dashboard_path
    assert_text move.from_group.location.name
    assert_text chat.name_with_arrows
    visit chat_path(chat)
    click_on t('ignore_all_and_see_chat')
    assert_text 'blabla'

    visit edit_user_registration_path
    click_on t('my_devise.cancel_my_account')
    page.accept_confirm
    assert_notice_message t('devise.registrations.destroyed')

    message.reload
    assert_equal t('user_canceled_account'), message.text
    assert_nil Move.find_by(id: move.id)
  end

  test 'signup with facebook which does not have email should allow instant login' do
    OmniAuth.config.test_mode = true
    email = 'my@email.com'
    password = 'password'
    facebook_uid = SecureRandom.hex
    OmniAuth.config.add_mock :facebook, uid: facebook_uid
    visit '/'
    find("a[title='#{t('my_devise.sign_in_with', provider: t('provider.facebook'))}']").click
    # we could directly visit user_facebook_omniauth_authorize_path
    fill_in t('neo4j.attributes.user.email'), with: email
    fill_in t('neo4j.attributes.user.password'), with: password
    fill_in t('neo4j.attributes.user.password_confirmation'), with: password
    click_on t('register')

    assert_user_logged_in_with_email email

    click_on 'my'
    click_on t('sign_out')
    find("a[title='#{t('my_devise.sign_in_with', provider: t('provider.facebook'))}']").click
    assert_user_logged_in_with_email email
    user = User.last
    assert_equal facebook_uid, user.facebook_uid

    OmniAuth.config.test_mode = false
  end
end
