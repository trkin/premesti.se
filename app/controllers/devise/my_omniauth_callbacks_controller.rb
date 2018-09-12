module Devise
  class MyOmniauthCallbacksController < OmniauthCallbacksController
    # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
    # data is in request.env["omniauth.auth"]
    %i[facebook google_oauth2].each do |provider|
      define_method provider do
        # use request.env["omniauth.params"]["my_param"]
        auth = request.env['omniauth.auth']
        result = UserFromOmniauth.new(auth, session[:referrer]).perform
        if result.success?
          sign_in_and_redirect result.user, event: :authentication
          set_flash_message(:notice, :success, kind: t("provider.#{provider}"))
        else
          set_flash_message(:alert, :success, kind: t("provider.#{provider}"))
          if provider == :facebook
            session[:auth] = auth
            session[:facebook_uid] = auth.uid
          end
          redirect_to new_user_registration_path, alert: result.message
        end
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
