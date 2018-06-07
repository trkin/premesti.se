# Preview all emails at http://sr.loc:3003/rails/mailers/user_mailer
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

  def new_match
    move = Move.first || FactoryBot.create(:move)
    chat = Chat.first || FactoryBot.create(:chat)
    UserMailer.new_match(move, chat)
  end
end
