class PagesController < ApplicationController
  def index
    @landing_signup = LandingSignup.new
  end

  def landing_signup
    landing_signup_params = params.require(:landing_signup).permit(LandingSignup::FIELDS)
    @landing_signup = LandingSignup.new landing_signup_params
    if @landing_signup.perform
      redirect_to dashboard_path, notice: @landing_signup.notice
    else
      flash.now[:alert] = @landing_signup.errors.full_messages.join(', ')
      render :index
    end
  end
end
