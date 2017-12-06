require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  def register(email)
    visit new_user_registration_path
    fill_in t("neo4j.attributes.user.email"), with: email
    fill_in t("neo4j.attributes.user.password"), with: 'password'
    fill_in t("neo4j.attributes.user.password_confirmation"), with: 'password'

    click_on t("my_devise.registration_headline")
  end

  test 'signup new user' do
    register 'new@email.com'

    assert_text t("devise.registrations.signed_up_but_unconfirmed")
  end

  test 'user already exists' do
    email = 'my@mail.com'
    create :user, email: email
    register email
    assert_text t("neo4j.attributes.user.email") + " " + t("neo4j.errors.messages.taken")
  end
end
