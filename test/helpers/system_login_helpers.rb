module SystemLoginHelpers
  def manual_login(email, password)
    visit new_user_session_path
    fill_in t('neo4j.attributes.user.email'), with: email
    fill_in t('neo4j.attributes.user.password'), with: password

    click_on t('sign_in')
  end

  def manual_register(email, password)
    visit new_user_registration_path
    fill_in t('neo4j.attributes.user.email'), with: email
    fill_in t('neo4j.attributes.user.password'), with: password
    fill_in t('neo4j.attributes.user.password_confirmation'), with: password

    click_on t('register')
  end
end
