class PagesController < ApplicationController
  def index
    @locations = Location.all
  end
end
