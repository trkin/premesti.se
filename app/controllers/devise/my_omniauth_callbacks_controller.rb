module Devise
  class MyOmniauthCallbacksController < OmniauthCallbacksController
    # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
    # data is in request.env["omniauth.auth"]
    %i[facebook google_oauth2].each do |provider|
      define_method provider do
        # use request.env["omniauth.params"]["my_param"]
        user = User.from_omniauth!(request.env['omniauth.auth'])
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: t("provider.#{provider}"))
      end
    end

    def failure
      # this could be: no_authorization_code # when we did not whitelisted domain
      # on facebook app settings
      message = " #{request.env['omniauth.error'].try(:message)} #{request.env['omniauth.error.type']}"
      redirect_to root_path, alert: t('my_devise.can_not_sign_in') + message
    end
  end
end
