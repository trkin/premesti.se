require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  def valid_params(group)
    {
      email: 'my@email.com',
      password: '123456',
      current_city: group.location.city.id,
      current_location: group.location.id,
      from_group_age: group.age,
      subscribe_to_new_match: '1',
    }
  end

  def valid?(attr = {})
    group = create :group
    LandingSignup.new(valid_params(group).merge(attr)).valid?
  end

  test 'validation' do
    assert valid?
    refute valid?(email: nil)
    refute valid?(email: '')
    refute valid?(from_group_age: nil)
    refute valid?(from_group_age: '')
  end

  test 'email format valid' do
    assert valid?(email: 'my@email.com')
    refute valid?(email: 'my@@email.com')
    refute valid?(email: 'my.email.com')
  end

  test 'create new user and move' do
    assert_difference 'User.count', 1 do
      assert_difference 'Move.count', 1 do
        group = create :group
        landing_signup = LandingSignup.new(valid_params(group))
        landing_signup.perform
        assert_equal valid_params(group)[:email], landing_signup.user.email
        assert_equal group.id, landing_signup.move.from_group.id
      end
    end
  end

  test '#locations_by_city_id' do
    c1 = create :city
    l1_c1 = create :location, city: c1
    l2_c1 = create :location, city: c1
    c2 = create :city
    l1_c2 = create :location, city: c2
    expected = {
      c2.id => [{ id: l1_c2.id, name: l1_c2.name_with_address }],
      c1.id => [{ id: l1_c1.id, name: l1_c1.name_with_address }, { id: l2_c1.id, name: l2_c1.name_with_address }],
    }
    actual = LandingSignup.locations_by_city_id
    assert_equal_hash_when_values_are_sorted_by_key expected, actual
  end

  test '#groups_by_location_id' do
    l1 = create :location
    g1_l1 = create :group, location: l1
    g2_l1 = create :group, location: l1
    l2 = create :location
    g1_l2 = create :group, location: l2
    expected = {
      l1.id => [{ id: g1_l1.id, name: g1_l1.age_with_title }, { id: g2_l1.id, name: g2_l1.age_with_title }],
      l2.id => [{ id: g1_l2.id, name: g1_l2.age_with_title }],
    }
    assert_equal_hash_when_values_are_sorted_by_key expected, LandingSignup.groups_by_location_id
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
      g1_l1.id => [{ id: g1_l2.id, name: l2.name_with_address }],
      g2_l1.id => [{ id: g1_l3.id, name: l3.name_with_address }],
      g1_l2.id => [{ id: g1_l1.id, name: l1.name_with_address }],
      g1_l3.id => [{ id: g2_l1.id, name: l1.name_with_address }],
      other_group.id => []
    }
    assert_equal result, LandingSignup.groups_by_group_id
  end
end
