require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test '#locations_by_city_id' do
    c1 = create :city
    l1_c1 = create :location, city: c1
    l2_c1 = create :location, city: c1
    c2 = create :city
    l1_c2 = create :location, city: c2
    result = {
      c1.id => [{ id: l1_c1.id, name: l1_c1.name }, { id: l2_c1.id, name: l2_c1.name }],
      c2.id => [{ id: l1_c2.id, name: l1_c2.name }]
    }
    assert_equal result, LandingSignup.locations_by_city_id
  end

  test '#groups_by_location_id' do
    l1 = create :location
    g1_l1 = create :group, location: l1
    g2_l1 = create :group, location: l1
    l2 = create :location
    g1_l2 = create :group, location: l2
    result = {
      l1.id => [{ id: g1_l1.id, name: g1_l1.name }, { id: g2_l1.id, name: g2_l1.name }],
      l2.id => [{ id: g1_l2.id, name: g1_l2.name }]
    }
    assert_equal result, LandingSignup.groups_by_location_id
  end

  test '#groups_by_group_id' do
    age = 5
    city = create :city
    l1 = create :location, city: city
    g1_l1 = create :group, location: l1, age: age
    g2_l1 = create :group, location: l1, age: age + 1
    l2 = create :location, city: city
    g1_l2 = create :group, location: l2, age: age
    l3 = create :location, city: city
    g1_l3 = create :group, location: l3, age: age + 1
    other_city = create :city
    other_location = create :location, city: other_city
    other_group = create :group, location: other_location, age: age
    result = {
      g1_l1.id => [{ id: g1_l2.id, name: l2.name }],
      g2_l1.id => [{ id: g1_l3.id, name: l3.name }],
      g1_l2.id => [{ id: g1_l1.id, name: l1.name }],
      g1_l3.id => [{ id: g2_l1.id, name: l1.name }],
      other_group.id => []
    }
    assert_equal result, LandingSignup.groups_by_group_id
  end
end
