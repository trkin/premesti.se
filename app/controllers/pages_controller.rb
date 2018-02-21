class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :_redirect_to_dashboard_for_authenticated_users, only: [:index]

  def index
    @landing_signup = LandingSignup.new
    @landing_signup.current_city = City.first
  end

  def landing_signup
    @landing_signup = LandingSignup.new landing_signup_params
    @landing_signup.current_city = City.first
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

  def _redirect_to_dashboard_for_authenticated_users
    redirect_to dashboard_path if current_user
  end

  def privacy_policy; end

  def find_on_map
    render layout: false
  end
end
