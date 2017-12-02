class LandingSignup
  include ActiveModel::Model
  attr_accessor :current_city, :current_location, :current_group,
                :prefered_groups, :email

  # return hash {city_id: [{id: l1.id, name: l1.name}, ...], ...}
  def self.locations_by_city_id
    Location.all.each_with_object({}) do |location, result|
      if result[location.city_id].present?
        result[location.city_id].append(id: location.id, name: location.name)
      else
        result[location.city_id] = [{ id: location.id, name: location.name }]
      end
    end
  end

  # return hash {location_id: [{id: group.id, name: group.name}, ...], ...}
  def self.groups_by_location_id
    Group.all.each_with_object({}) do |group, result|
      if result[group.location_id].present?
        result[group.location_id].append(id: group.id, name: group.name)
      else
        result[group.location_id] = [{ id: group.id, name: group.name }]
      end
    end
  end

  # return hash {group_id: [id: group.id, name: group.location.name}, ...]...}
  # groups on other locations from same city
  def self.groups_by_group_id
    Group.all.each_with_object({}) do |group, result|
      groups = group
               .query_as(:g)
               .match(
                 '(g)<-[:HAS_GROUPS]-(l), (l)-[:IN_CITY]->(c),(c)<-[:IN_CITY]-(other_loc), (other_loc)-[:HAS_GROUPS]->(other_group)'
               )
               .where('g <> other_group').where('g.age = other_group.age').pluck(:other_group)
               .map { |g| { id: g.id, name: g.location.name } }
      result[group.id] = groups
    end
  end
end
