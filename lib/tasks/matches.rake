namespace :matches do
  desc 'Find matches with greater length'
  task find_all: :environment do
    I18n.locale = :sr
    Move.all.each do |move|
      move.to_groups.each do |to_group|
        results = AddToGroupAndSendNotifications.new(move, to_group).create_and_send_notifications max_length_of_the_rotation: 8
        puts "move_id=#{move.id} group_id=#{to_group.id} #{results.message}"
      end
    end
  end
end
