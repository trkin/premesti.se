class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :_set_locale_from_domain
  before_action :authenticate_user!

  def _set_locale_from_domain
    locale = case request.host
             when 'www.premesti.se', 'sr.localhost'
               'sr'
             else
               I18n.default_locale
             end
    I18n.locale = locale
  end

  def after_sign_in_path_for(resource)
    redirect_url = stored_location_for(resource)
    return redirect_url if redirect_url.present?
    dashboard_path
  end
end
