require 'test_helper'
load 'app/helpers/mailer_helper.rb'

class UserMailerTest < ActionMailer::TestCase
  test 'landing_signup' do
    move = create :move
    mail = UserMailer.landing_signup(move.id)
    assert_equal t('user_mailer.landing_signup.subject'), mail.subject
    assert_equal [move.user.email], mail.to
    assert Rails.application.secrets.mailer_sender.include?(mail.from.first)
    assert_match t('hi_name', name: move.user.email), mail.body.encoded
    refute_match t('user_mailer.landing_signup.confirmation_text'), mail.body.encoded
  end

  test 'landing_signup with confirmation link' do
    user = create :unconfirmed_user
    move = create :move, user: user
    mail = UserMailer.landing_signup(move.id)
    assert_match t('user_mailer.landing_signup.description_of_service_unconfirmed'), mail.body.encoded
  end

  test 'new_match' do
    move = create :move
    chat = Chat.create_for_moves [move]
    mail = UserMailer.new_match(move.id, chat.id)
    assert_match t('new_match'), mail.subject
    assert_match t('user_mailer.new_match.chat_link'), mail.body.encoded
  end

  test 'new_match locale based on user locale' do
    user = create :user, locale: :sr
    move = create :move, user: user
    chat = Chat.create_for_moves [move]
    mail = UserMailer.new_match(move.id, chat.id)
    assert_match t('new_match', locale: :sr), mail.subject
    assert_match t('user_mailer.new_match.chat_link', locale: :sr), mail.body.encoded
    user.locale = :en
    user.save!
    move.reload
    mail = UserMailer.new_match(move.id, chat.id)
    assert_match t('new_match', locale: :en), mail.subject
    assert_match t('user_mailer.new_match.chat_link', locale: :en), mail.body.encoded
  end

  test 'new_message' do
    user = create :user
    move = create :move, user: user
    move_creator = create :move
    chat = Chat.create_for_moves [move, move_creator]
    message = create :message, chat: chat, user: move_creator.user, text: 'do_you_want_to_replace'
    mail = UserMailer.new_message(move.id, message.id)
    assert_equal [user.email], mail.to
    assert_match t('new_message'), mail.subject
    assert_match t('user_mailer.new_message.chat_link'), mail.body.encoded
    assert_match 'do_you_want_...', mail.body.encoded
  end

  class TestMailerHelper
    include MailerHelper
  end
  test 'strip_with_dots' do
    text = '123456789012345'
    expected = '123456789012...'
    assert_equal expected, TestMailerHelper.new.strip_with_dots(text)

    text = '1234567890123'
    expected = '123456789012...'
    assert_equal expected, TestMailerHelper.new.strip_with_dots(text)

    text = '123456789012'
    expected = '123456789...'
    assert_equal expected, TestMailerHelper.new.strip_with_dots(text)

    text = '1234'
    expected = '1...'
    assert_equal expected, TestMailerHelper.new.strip_with_dots(text)

    text = '123'
    expected = '123'
    assert_equal expected, TestMailerHelper.new.strip_with_dots(text)

    text = '1'
    expected = '1'
    assert_equal expected, TestMailerHelper.new.strip_with_dots(text)
  end
end
