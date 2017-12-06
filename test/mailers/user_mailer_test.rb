require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "landing_signup" do
    move = create :move
    mail = UserMailer.landing_signup(move)
    assert_equal t("user_mailer.landing_signup.subject"), mail.subject
    assert_equal [move.user.email], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Welcome", mail.body.encoded
  end
end
