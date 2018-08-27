module Devise
  class MyRegistrationsController < RegistrationsController
    def destroy
      Notify.message "destroy_user #{resource.email}", my_data: resource.my_data
      resource.destroy_moves_and_messages
      super
    end
  end
end
