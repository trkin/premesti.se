class ConfirmationsController < Devise::ConfirmationsController
  def show
    super
    return unless resource.confirmed?
    sign_in resource
    notice = []
    resource.moves.each do |move|
      move.to_groups.each do |to_group|
        result = AddToGroupAndSendNotifications.new(move, to_group).create_and_send_notifications
        notice << result.message
      end
    end
    flash[:notice] = notice.join(', ')
  end
end
