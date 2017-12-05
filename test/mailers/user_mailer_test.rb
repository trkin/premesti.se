require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "landing_signup" do
    mail = UserMailer.landing_signup
    assert_equal t("user_mailer.landing_signup.subject"), mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
