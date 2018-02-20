namespace :db do
  desc 'seed'
  task seed: :environment do
    b = {}
    # User
    [
      { var: :admin, email: 'admin@asdf.asdf', admin: true },
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

    # City
    [
      { var: :city1 },
      { var: :city2 },
    ].each do |doc|
      params = doc.except(:var).merge(name: doc[:var])
      city = City.find_by params
      if city.blank?
        city = City.create! params
        puts "City #{city.name}"
      end
      b[doc[:var]] = city if doc[:var]
    end

    # Location
    [
      { var: :loc1_city1, city: b[:city1], address: 'address1' },
      { var: :loc2_city1, city: b[:city1], address: 'address2' },
      { var: :loc3_city1, city: b[:city1], address: 'address3' },
      { var: :loc1_city2, city: b[:city2], address: 'address4' },
      { var: :loc2_city2, city: b[:city2], address: 'address5' },
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
      { var: :g2_l1, location: b[:loc1_city1], age: 2 },
      { var: :g2_l2, location: b[:loc2_city1], age: 2 },
      { var: :g2_l3, location: b[:loc3_city1], age: 2 },
      { var: :g2_l4, location: b[:loc1_city2], age: 2 },
      { var: :g2_l5, location: b[:loc2_city2], age: 2 },
      { var: :g4_l1, location: b[:loc1_city1], age: 4 },
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
      { var: :m1_l1_l2, from_group: b[:g2_l1], to_groups: b[:g2_l2],
        user: b[:user1] },
      { var: :m1_l1_l3, from_group: b[:g2_l1], to_groups: b[:g2_l3],
        user: b[:user1] },
      { var: :m2_l3_l4, from_group: b[:g2_l3], to_groups: b[:g2_l4],
        user: b[:user2], available_from_date:
        Date.today.end_of_month },
      { var: :m3_l4_l1, from_group: b[:g2_l4], to_groups: b[:g2_l1],
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
    Rake::Task["neo4j:stop"].invoke Rails.env
    puts sh "rm -rf db/neo4j/#{Rails.env}/data/databases/graph.db"
    Rake::Task["neo4j:start"].invoke Rails.env
    puts "Find database on http://" +
         Rails.application.secrets.neo4j_host.to_s + ":" +
         (Rails.application.secrets.neo4j_port.to_i + 2).to_s
  end

  desc 'migrate'
  task migrate: :environment do
    puts "running neo4j:migrate"
    Rake::Task["neo4j:migrate"].invoke Rails.env
  end

  desc 'setup = drop, migrate and seed'
  task setup: :environment do
    puts 'this is not implemented'
    puts 'since drop need some time to bootup, and migrate raises exception'
  end
end
