class Admin::GroupsController < AdminController
  before_action :set_location, only: %i[index new create]
  before_action :set_group, only: %i[edit update destroy]

  def index; end

  def new
    @group = @location.groups.new
    render layout: false
  end

  def create
    @group = Group.new group_params.merge(
      location: @location
    )
    @group.save
  end

  def edit
    render layout: false
  end

  def update
    @group.update group_params
  end

  def destroy
    location = @group.location
    @group.destroy
    redirect_to admin_location_path(location)
  end

  private

  def set_location
    redirect_to admin_dashboard_path unless params[:location]
    @location = Location.find_by name: params[:location]
  end

  def set_group
    @group = Group.find params[:id]
  end

  def group_params
    params.require(:group).permit(
      :name, :age
    )
  end
end
