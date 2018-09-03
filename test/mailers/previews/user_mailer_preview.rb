# Preview all emails at http://sr.loc:3003/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/landing_signup
  def landing_signup
    move = Move.first || create(:move)
    UserMailer.landing_signup(move.id)
  end

  def landing_signup_unconfirmed
    user = User.where(confirmed_at: nil).first
    user ||= create(:user, confirmed_at: nil)
    move = create :move, user: user
    UserMailer.landing_signup(move.id)
  end

  def new_match
    move = Move.first || create(:move)
    chat = Chat.first || create(:chat)
    UserMailer.new_match(move.id, chat.id)
  end

  def new_message
    user = create :user
    move = create :move, user: user
    move_creator = create :move
    chat = Chat.create_for_moves [move, move_creator]
    message = create :message, chat: chat, user: move_creator.user, text: 'do_you_want_to_replace'
    UserMailer.new_message(move.id, message.id)
  end

  def notification
    user = create :user
    subject = 'This is subject'
    message = '<h1>Message Header</h1> message body'
    UserMailer.notification(user, subject, message)
  end
end
