class AdminController < ApplicationController
  before_action :check_admin

  def dashboard
    redirect_to(admin_locations_path(city_id: City.last.id)) && return if City.all.size == 1
  end

  def check_admin
    redirect_to(root_path) unless current_user.admin?
  end
end
