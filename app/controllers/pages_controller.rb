class PagesController < ApplicationController
  def index
    @landing_signup = LandingSignup.new
  end

  def landing_signup
    @landing_signup = LandingSignup.new params.require(:landing_signup).permit(LandingSignup::FIELDS)
    if @landing_signup.perform
      redirect_to dashboard_path
    else
      render :index
    end
  end
end
