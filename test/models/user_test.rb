require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'email format' do
    user = build :user, email: 'asd@asd.asd'
    assert user.valid?

    user = build :user, email: 'asd@asd'
    refute user.valid?
  end
end
