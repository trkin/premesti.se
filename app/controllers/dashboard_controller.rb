class DashboardController < ApplicationController
  def index; end

  def resend_confirmation_instructions
    current_user.send_confirmation_instructions
    redirect_to dashboard_path, notice: t('devise.registrations.signed_up_but_unconfirmed')
  end

  def moves_for_age
    return [] unless params[:age].present?

    @moves = \
      Move
      .query_as(:m)
      .match('(m)-[:CURRENT]-(g)')
      .where(g: { age: params[:age].to_i })
      .proxy_as(Move, :m)
      .page(params[:page])
  end
end
