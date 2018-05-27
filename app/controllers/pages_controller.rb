class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    @landing_signup = LandingSignup.new
  end

  def landing_signup
    @landing_signup = LandingSignup.new _landing_signup_params
    if @landing_signup.perform
      sign_in @landing_signup.user
      redirect_to dashboard_path, notice: @landing_signup.notice
    else
      flash.now[:alert] = @landing_signup.errors.full_messages.join(', ')
      render :home
    end
  end

  def my_move
    @move = Move.find params[:id]
    @landing_signup = LandingSignup.new
    @landing_signup.from_group_age = @move.from_group.age
    @landing_signup.current_location = @move.to_groups.first&.location&.id
    @landing_signup.to_location = @move.from_group.location.id
  end

  def submit_my_move
    @move = Move.find params[:id]
    @landing_signup = LandingSignup.new _landing_signup_params
    if @landing_signup.perform
      sign_in @landing_signup.user
      redirect_to dashboard_path, notice: @landing_signup.notice
    else
      flash.now[:alert] = @landing_signup.errors.full_messages.join(', ')
      render :my_move
    end
  end

  def select2_locations
    results = Select2LocationsService.new(params[:term]).perform
    render json: { results: results }
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
    else
      flash.now[:alert] = @contact_form.errors.full_messages.join(', ')
    end
    render :contact
  end

  def _landing_signup_params
    params.require(:landing_signup).permit(
      LandingSignup::FIELDS
    ).merge(
      current_user: current_user,
      current_city: City.first,
    )
  end
end
