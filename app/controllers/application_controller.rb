class ApplicationController < ActionController::Base
  include TranslateHelper
  protect_from_forgery with: :exception
  before_action :_set_locale_from_domain
  before_action :authenticate_user!

  def _set_locale_from_domain
    locale = case request.host
             when Constant::DOMAINS[:production][:sr], Constant::DOMAINS[:development][:sr]
               :sr
             when Constant::DOMAINS[:production][:'sr-latin'], Constant::DOMAINS[:development][:'sr-latin']
               :'sr-latin'
             when Constant::DOMAINS[:production][:en], Constant::DOMAINS[:development][:en]
               :en
             else
               I18n.default_locale
             end
    locale = :en if Rails.env.test?
    I18n.locale = locale
  end

  def after_sign_in_path_for(resource)
    redirect_url = stored_location_for(resource)
    return redirect_url if redirect_url.present?
    dashboard_path
  end
end
