require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'should not save without name' do
    group = build :group
    group.name = ''
    assert_not group.valid?
  end

  test 'should not save without location' do
    group = build :group
    group.location = nil
    assert_not group.valid?
  end
end
