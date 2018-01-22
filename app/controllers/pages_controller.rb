class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @landing_signup = LandingSignup.new
  end

  def landing_signup
    @landing_signup = LandingSignup.new landing_signup_params
    if @landing_signup.perform
      sign_in @landing_signup.user
      redirect_to dashboard_path, notice: @landing_signup.notice
    else
      flash.now[:alert] = @landing_signup.errors.full_messages.join(', ')
      render :index
    end
  end

  def landing_signup_params
    params.require(:landing_signup).permit(LandingSignup::FIELDS)
  end
end
