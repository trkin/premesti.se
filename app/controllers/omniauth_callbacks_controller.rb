class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  # data is in request.env["omniauth.auth"]
  %i[facebook google_oauth2].each do |provider|
    define_method provider do
      # use request.env["omniauth.params"]["my_param"]
      user = User.from_omniauth!(request.env["omniauth.auth"])
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: provider)
    end
  end

  def failure
    # this could be: no_authorization_code # when we did not whitelisted domain
    # on facebook app settings
    redirect_to root_path, alert: "Can't sign in. #{request.env['omniauth.error'].try(:message)} #{request.env['omniauth.error.type']}"
  end
end
