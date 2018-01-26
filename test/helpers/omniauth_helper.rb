module OmniauthHelper
  # rubocop:disable Metrics/MethodLength
  def mock_facebook_auth(user = {})
    # info https://github.com/omniauth/omniauth/wiki/Integration-Testing
    auth = {
      provider: 'facebook',
      uid: user.try(:facebook_uid) || '1234567',
      info: {
        email: user.try(:email) || 'joe@bloggs.com',
        name: user.try(:name) || 'Joe Bloggs',
        first_name: 'Joe',
        last_name: 'Bloggs',
        image: 'http://graph.facebook.com/1234567/picture?type=square',
        verified: true
      },
      credentials: {
        token: 'ABCDEF...', # OAuth 2.0 access_token, which you may wish to store
        expires_at: '1321747205', # when the access token expires (it always will)
        expires: true # this will always be true
      },
    }

    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:facebook, auth)
  end

  def mock_facebook_invalid_auth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
  end

  def silence_omniauth
    previous_logger = OmniAuth.config.logger
    OmniAuth.config.logger = Logger.new("/dev/null")
    yield
  ensure
    OmniAuth.config.logger = previous_logger
  end
end
