module Devise
  class MyRegistrationsController < RegistrationsController
    def create
      super do |user|
        if session[:auth].present?
          user.auth = session[:auth]
          user.facebook_uid = session[:facebook_uid]
          user.save! if user.valid?
        end
        if session[:referrer].present?
          user.initial_referrer = session[:referrer]
          user.save! if user.valid?
        end
      end
    end

    def destroy
      Notify.message "destroy_user #{resource.email}", any_reason: params[:any_reason], my_data: resource.my_data
      resource.destroy_moves_and_messages params[:any_reason].presence
      super
    end
  end
end
