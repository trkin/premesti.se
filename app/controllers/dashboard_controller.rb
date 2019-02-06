class DashboardController < ApplicationController
  def index; end

  def resend_confirmation_instructions
    current_user.send_confirmation_instructions
    redirect_to dashboard_path, notice: t('devise.registrations.signed_up_but_unconfirmed')
  end

  def moves_for_age
    @moves = if params[:age].present?
               Move.for_age params[:age].to_i
             else
               []
             end
  end
end
