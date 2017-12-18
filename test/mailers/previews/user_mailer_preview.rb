# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/landing_signup
  def landing_signup
    move = Move.first || FactoryBot.create(:move)
    UserMailer.landing_signup(move)
  end

  def landing_signup_unconfirmed
    user = User.where(confirmed_at: nil).first
    user ||= FactoryBot.create(:user, confirmed_at: nil)
    move = FactoryBot.create :move, user: user
    UserMailer.landing_signup(move)
  end
end
