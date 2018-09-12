module Devise
  class MyRegistrationsController < RegistrationsController
    def create
      super do |user|
        if session[:auth].present?
          user.auth = session[:auth]
          user.facebook_uid = session[:facebook_uid]
          user.save!
        end
        if session[:referrer].present?
          user.initial_referrer = session[:referrer]
          user.save!
        end
      end
    end

    def destroy
      Notify.message "destroy_user #{resource.email}", my_data: resource.my_data
      resource.destroy_moves_and_messages
      super
    end
  end
end
