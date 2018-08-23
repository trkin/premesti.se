module Devise
  class MyRegistrationsController < RegistrationsController
    def destroy
      Notify.message "destroy_user #{resource.email}", my_data: resource.my_data
      super
    end
  end
end
