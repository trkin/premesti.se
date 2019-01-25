class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: %i[
    sample_error_in_javascript notify_javascript_error
  ]

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
    @move = Move.find_by id: params[:id]
    redirect_to root_path, alert: t('this_move_was_deleted') and return unless @move
    @landing_signup = LandingSignup.new
    @landing_signup.from_group_age = @move.from_group.age
    @landing_signup.current_location = @move.to_groups.first&.location&.id
    # @landing_signup.to_location = @move.from_group.location.id
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
      g_recaptcha_response: params['g-recaptcha-response'],
      current_user: current_user,
      remote_ip: request.remote_ip,
    )
    if @contact_form.save
      flash.now[:notice] = t('contact_thanks')
      contact
    else
      flash.now[:alert] = @contact_form.errors.full_messages.join(', ')
    end
    render :contact
  end

  def sample_error
    raise 'This is sample_error on server'
  end

  def sample_error_in_javascript
    render layout: true, html: %(
      Calling manual_js_error_now
      <script>
        function manual_js_error_now_function() {
          manual_js_error_now
        }
        console.log('calling manual_js_error_now');
        manual_js_error_now_function();
        // you can also trigger error on window.onload = function() { manual_js_error_onload }
      </script>
      <br>
      <button onclick="trigger_js_error_on_click">Trigger error on click</button>
      <a href="/sample-error-in-javascript-ajax" data-remote="true" id="l">Trigger error in ajax</a>
    ).html_safe
  end

  def sample_error_in_javascript_ajax
    render js: %(
      console.log("starting sample_error_in_javascript_ajax");
      sample_error_in_javascript_ajax
    )
  end

  def notify_javascript_error
    js_receivers = Rails.application.secrets.javascript_error_recipients
    if js_receivers.present?
      ExceptionNotifier.notify_exception(
        Exception.new(params[:errorMsg]),
        env: request.env,
        exception_recipients: js_receivers.to_s.split(','),
        data: {
          current_user: current_user,
          params: params
        }
      )
    end
    head :ok
  end

  def sample_error_in_sidekiq
    TaskWithErrorJob.perform_later
    render plain: 'TaskWithErrorJob in queue, please run: sidekiq'
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
