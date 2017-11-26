namespace :db do
  desc 'seed'
  task seed: :environment do
    b = {}
    # User
    [
      { var: :user1, email: 'asdf1@asdf.asdf' },
      { var: :user2, email: 'asdf2@asdf.asdf' },
      { var: :user3, email: 'asdf3@asdf.asdf' },
    ].each do |doc|
      params = doc.except(:var).merge(name: doc[:var])
      user = User.find_by params
      unless user.present?
        user = User.create! params.merge(password: 'asdfasdf', confirmed_at: Time.zone.now)
        puts "User #{user.email}"
      end
      b[doc[:var]] = user if doc[:var]
    end

    # Location
    [
      { var: :location1 },
      { var: :location2 },
      { var: :location3 },
      { var: :location4 },
      { var: :location5 },
    ].each do |doc|
      params = doc.except(:var).merge(name: doc[:var])
      location = Location.find_by params
      if location.blank?
        location = Location.create! params
        puts "Location #{location.name}"
      end
      b[doc[:var]] = location if doc[:var]
    end

    # Group
    [
      { var: :g2_l1, location: b[:location1], age_min: 2,
        age_max: 2 },
      { var: :g2_l2, location: b[:location2], age_min: 2,
        age_max: 2 },
      { var: :g2_l3, location: b[:location3], age_min: 2,
        age_max: 2 },
      { var: :g2_l4, location: b[:location4], age_min: 2,
        age_max: 2 },
      { var: :g2_l5, location: b[:location5], age_min: 2,
        age_max: 2 },
      { var: :g4_l1, location: b[:location1], age_min: 4,
        age_max: 4 },
    ].each do |doc|
      params = doc.except(:var).merge(name: doc[:var])
      group = Group.find_by params
      unless group.present?
        group = Group.create! params
        puts "Group #{group.name}"
      end
      b[doc[:var]] = group if doc[:var]
    end

    # Move
    [
      { var: :m1_l1_l2, from_group: b[:g2_l1], prefered_groups: b[:g2_l2],
        user: b[:user1] },
      { var: :m1_l1_l3, from_group: b[:g2_l1], prefered_groups: b[:g2_l3],
        user: b[:user1] },
      { var: :m2_l3_l4, from_group: b[:g2_l3], prefered_groups: b[:g2_l4],
        user: b[:user2], available_from_date:
        Date.today.end_of_month },
      { var: :m3_l4_l1, from_group: b[:g2_l4], prefered_groups: b[:g2_l1],
        user: b[:user3], }
    ].each do |doc|
      params = doc.except(:var).merge(name: doc[:var])
      move = Move.find_by params
      unless move.present?
        move = Move.create! params
        puts "Move #{move.name}"
      end
    end
  end

  desc 'drop'
  task drop: :environment do
    Rake::Task["neo4j:stop"].execute
    puts sh 'rm -rf db/neo4j/development/data/databases/graph.db'
    Rake::Task["neo4j:start"].execute
    puts "http://" +
         Rails.application.secrets.neo4j_host.to_s + ":" +
         (Rails.application.secrets.neo4j_bolt_port.to_i + 2).to_s
  end

  desc 'migrate'
  task migrate: :environment do
    puts "running neo4j:migrate"
    Rake::Task["neo4j:migrate"].execute
  end

  desc 'setup = drop, migrate and seed'
  task setup: :environment do
    puts 'this is not implemented'
    puts 'since drop need some time to bootup, and migrate raises exception'
  end
end
