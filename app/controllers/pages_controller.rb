class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :_redirect_to_dashboard_for_authenticated_users, only: [:home]

  def home
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
      render :home
    end
  end

  def select2_locations
    results = Select2LocationsService.new(params[:term]).perform
    render json: { results: results }
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

  def contact
    @contact_form = ContactForm.new(
      email: current_user&.email
    )
  end

  def submit_contact
    @contact_form = ContactForm.new(
      email: current_user&.email || params[:contact_form][:email],
      text: params[:contact_form][:text],
    )
    if @contact_form.perform
      flash.now[:notice] = t('contact_thanks')
      render :contact_thanks
    else
      flash.now[:alert] = @contact_form.errors.full_messages.join(', ')
      render :contact
    end
  end
end
