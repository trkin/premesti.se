class UserMailer < ApplicationMailer
  def landing_signup(move)
    @move = move

    mail to: @move.user.email
  end
end
