class PagesController < ApplicationController
  def index
    @locations = Location.all
    @landing_signup = LandingSignup.new
  end
end
