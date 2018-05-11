require 'test_helper'

class MoveTest < ActiveSupport::TestCase
  test 'check same age' do
    from_group1 = build :group, age: 1
    move = build :move, from_group: from_group1
    assert move.valid?

    group1 = build :group, age: 1
    move.to_groups << group1
    assert move.valid?

    group2 = build :group, age: 2
    move.to_groups << group2
    assert_not move.valid?
  end
end

