class ApplicationController < ActionController::Base
  include TranslateHelper
  protect_from_forgery with: :exception
  before_action :_set_locale_from_domain
  before_action :authenticate_user!, except: [:sign_in_as]
  # before_action :sleep_some_time # add delay for testing real conditions

  def sleep_some_time
    sleep 1
  end

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

  def sign_in_as
    return unless Rails.env.development?
    user = User.find params[:user_id]
    sign_in :user, user, byepass: true
    redirect_to root_path
  end
end
