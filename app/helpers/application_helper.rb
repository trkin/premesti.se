module ApplicationHelper
  def login_layout(login_title = nil, attr = {})
    @login_title = login_title
    @login_layout = attr
  end

  def login_layout?
    @login_layout
  end

  def login_title
    @login_title
  end

  def landing_layout
    @landing_layout = true
  end

  def landing_layout?
    @landing_layout
  end

  def breadcrumb(list = {})
    @breadcrumb = { I18n.t('dashboard') => (list.present? ? dashboard_path : nil) }.merge list
  end

  def find_breadcrumb_list
    @breadcrumb || []
  end

  def meta_tags(hash)
    content_for(:meta_tags) do
      hash.map do |key, value|
        "<meta property='#{key}' content='#{value}'/>"
      end.join.html_safe
    end
  end

  def site_description(site_description)
    @site_description = site_description
  end

  def find_site_description
    @site_description || t('site_description')
  end

  def link_for_current_user_locale
    # clear subdomain www and change domain
    link = root_url(subdomain: nil, domain: Constant::DOMAINS[Rails.env.to_sym][current_user.locale.to_sym])
    "<a href='#{link}'>#{link}</a>"
  end

  def alert_for_user
    alert = ''
    return alert unless current_user
    unless current_user.confirmed?
      alert += t('my_devise.confirm_your_email_to_start_receiving_notifications', confirmation_url: resend_confirmation_instructions_path)
    end
    if current_user.locale != I18n.locale.to_s
      language = t('current_language', locale: current_user.locale)
      settings_link = "<a href='#{my_settings_path}'>#{my_settings_path}</a>"
      alert += t('visit_link_to_switch_language', language: language, link:
                 link_for_current_user_locale, settings_link: settings_link)
    end
    alert
  end

  # this is used for devise mailer
  # https://stackoverflow.com/questions/19456339/how-to-run-rails-devise-method-edit-password-url-by-hand
  def main_app
    Rails.application.class.routes.url_helpers
  end

  def paginate_explanation(records)
    <<~HERE_DOC
      #{(records.current_page - 1) * records.per_page + 1}
      -
      #{[records.current_page * records.per_page, records.total_count].min}
      #{t('from_total')}
      #{records.total_count}
    HERE_DOC
  end
end
