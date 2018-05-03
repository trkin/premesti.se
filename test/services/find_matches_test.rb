# rubocop:disable Naming/VariableName
require 'test_helper'
class FindMatchesTest < ActiveSupport::TestCase
  include PauseHelper
  def test_ab
    city = create :city
    locationA = create :location, city: city
    groupA1 = create :group, age: 1, location: locationA
    locationB = create :location, city: city
    groupB1 = create :group, age: 1, location: locationB
    moveAB = create :move, from_group: groupA1, to_groups: groupB1
    moveBA = create :move, from_group: groupB1, to_groups: groupA1

    matches = [
      [moveBA, moveAB],
      [moveAB, moveBA],
    ]
    results = FindMatches.perform
    assert_equal matches, results
  end

  def test_ab_not_same_age
    city = create :city
    locationA = create :location, city: city
    groupA1 = create :group, age: 1, location: locationA
    groupA2 = create :group, age: 2, location: locationA
    locationB = create :location, city: city
    groupB1 = create :group, age: 1, location: locationB
    _moveAB = create :move, from_group: groupA1, to_groups: groupB1
    _moveBA = create :move, from_group: groupB1, to_groups: groupA2

    matches = []
    results = FindMatches.perform
    assert_equal matches, results
  end

  def test_abc
    city = create :city
    locationA = create :location, city: city
    groupA1 = create :group, age: 1, location: locationA
    locationB = create :location, city: city
    groupB1 = create :group, age: 1, location: locationB
    locationC = create :location, city: city
    groupC1 = create :group, age: 1, location: locationC
    moveAB = create :move, from_group: groupA1, to_groups: groupB1
    moveBC = create :move, from_group: groupB1, to_groups: groupC1
    moveCA = create :move, from_group: groupC1, to_groups: groupA1

    matches = [
      [moveAB, moveCA, moveBC],
      [moveBC, moveAB, moveCA],
      [moveCA, moveBC, moveAB],
    ]
    results = FindMatches.perform
    assert_equal matches, results
  end
end
