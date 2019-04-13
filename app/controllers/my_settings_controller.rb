class MySettingsController < ApplicationController
  def index; end

  def update
    previous_locale = current_user.locale
    if current_user.update _my_settings_params
      notice = t_crud('success_update', User)
      if current_user.locale != previous_locale && current_user.locale != I18n.locale.to_s
        notice += '<br>' + t('visit_link_to_start_using_new_language', link: view_context.link_for_current_user_locale)
      end
      redirect_to my_settings_path, notice: notice
    else
      redirect_to my_settings_path, alert: current_user.errors.join
    end
  end

  def my_data; end

  def _my_settings_params
    params.require(:user).permit(
      :locale, :subscribe_to_new_match,
      :subscribe_to_news_mailing_list, :phone_number, :visible_email_address,
      :initial_chat_message,
    )
  end
end
