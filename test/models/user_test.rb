require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '.from_omniauth existing by email' do
    email = 'my@email.com'
    user = create :user, email: email
    auth = OpenStruct.new(
      provider: 'facebook',
      info: OpenStruct.new(
        email: email,
      ),
    )
    assert_equal user, User.from_omniauth!(auth)
  end

  test '.from_omniauth existing by uid' do
    uid = 'uid123'
    user = create :user, facebook_uid: uid
    auth = OpenStruct.new(
      provider: 'facebook',
      uid: uid,
      info: OpenStruct.new,
    )
    assert_equal user, User.from_omniauth!(auth)
  end

  test '.from_omniauth create' do
    email = 'my@email.com'
    auth = OpenStruct.new(
      provider: 'facebook',
      info: OpenStruct.new(
        email: email,
      ),
    )
    assert_difference "User.count", 1 do
      user = User.from_omniauth!(auth)
      assert_equal email, user.email
      assert user.confirmed?
    end
  end
end
