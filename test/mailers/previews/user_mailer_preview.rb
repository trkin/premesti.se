# Preview all emails at http://sr.loc:3003/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods
  # do not create data since it will remain in your development database
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
    user = User.first || create(:user)
    move = create :move, user: user
    missing_move = create :move, user: user
    chat = Chat.first || create(:chat)
    UserMailer.new_match(move.id, missing_move.id, chat.id)
  end

  def new_message
    user = User.first || create(:user)
    move = Move.first || create(:move, user: user)
    move_creator = Move.first || create(:move, user: user)
    message = Message.first
    message ||= create(:message, chat: Chat.create_for_moves(move, move_creator), user: move_creator.user, text: 'hello')
    UserMailer.new_message(move.id, message.id)
  end

  def notification
    user = User.first || create(:user)
    subject = 'This is subject'
    message = '<h1>Message Header</h1> message body'
    UserMailer.notification(user, subject, message)
  end
end
