require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should not save without name' do
    group = build :group
    group.age = nil
    assert_not group.valid?
  end

  test 'should not save without location' do
    group = build :group
    group.location = nil
    assert_not group.valid?
  end

  test 'destroy should not destroy moves that point to group' do
    group = create :group
    create :move, from_group: group
    assert_difference "Group.count", -1 do
      assert_difference "Move.count", 0 do
        group.destroy
      end
    end
  end
end
