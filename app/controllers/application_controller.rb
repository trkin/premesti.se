class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :_set_locale_from_domain

  def _set_locale_from_domain
    locale = case request.host
             when 'www.premesti.se', 'sr.localhost'
               'sr'
             else
               I18n.default_locale
             end
    I18n.locale = locale
  end
end
