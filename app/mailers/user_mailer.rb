class UserMailer < ApplicationMailer
  def landing_signup(move = nil, user_password = nil)
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
