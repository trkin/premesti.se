class ConfirmationsController < Devise::ConfirmationsController
  def show
    super
    sign_in resource if resource.confirmed?
  end
end
