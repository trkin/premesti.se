class ApplicationController < ActionController::Base
  include TranslateHelper
  protect_from_forgery with: :exception
  before_action :_set_locale_from_domain
  before_action :authenticate_user!, except: [:sign_in_as]
  # before_action :sleep_some_time # add delay for testing real conditions
  after_action :check_flash_message
  before_action :save_referrer
  before_action :_redirect_to_trk

  # rubocop:disable Metrics/AbcSize
  def check_flash_message
    return unless request.xhr? && request.format.js?

    response.body += "flash_alert('#{view_context.j flash.now[:alert]}');" if flash.now[:alert].present?
    response.body += "flash_notice('#{view_context.j flash.now[:notice]}');" if flash.now[:notice].present?
  end
  # rubocop:enable Metrics/AbcSize

  def save_referrer
    return if session['referrer'].present?

    if params[:utm_campaign].present?
      session[:referrer] = params[:utm_campaign]
    elsif request.env[:HTTP_REFERER].present?
      session[:referrer] = request.env[:HTTP_REFERER]
    else
      session['referrer'] = Constant::DOMAINS[:production][:sr]
    end
  end

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
    I18n.locale = locale
  end

  def after_sign_in_path_for(resource)
    Notify.message('non_active_user_logged_in ' + resource.email, resource) unless resource.active?
    redirect_url = stored_location_for(resource)
    return redirect_url if redirect_url.present?
    dashboard_path
  end

  def sign_in_as
    redirect_to(root_path, alert: t(:unauthorized)) && return unless current_user&.admin? || Rails.env.development?
    user = User.find params[:user_id]
    request.env['devise.skip_trackable'] = true
    sign_in :user, user, byepass: true
    redirect_to root_path, notice: t(:successfully)
  end

  def _redirect_to_trk
    return unless %w[premesti.se www.premesti.se sr-latin.premesti.se en.premesti.se].include? request.host

    link = Rails.application.secrets.default_url.symbolize_keys
    port = (Rails.env.development? ? ":#{link[:port]}" : '')
    redirect_to request.protocol + Constant::DOMAINS[Rails.env.to_sym][:sr] + port
  end

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[locale auth facebook_uid])
  end
end
