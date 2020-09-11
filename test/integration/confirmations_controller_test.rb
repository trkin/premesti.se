require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test 'users moves are touched and included in chats' do
    age = 2
    group_a = create :group, name: 'A', age: age
    group_b = create :group, name: 'B', age: age
    create :move, from_group: group_a, to_groups: [group_b]
    user = create :unconfirmed_user
    create :move, user: user, from_group: group_b, to_groups: [group_a]
    assert_difference 'Chat.count', 1 do
      assert_performed_jobs 3 do
        perform_enqueued_jobs do
          get user_confirmation_path(confirmation_token: user.confirmation_token)
        end
      end
    end
    follow_redirect!
    follow_redirect!

    chat_mail, another_chat_mail = give_me_all_mail_and_clear_mails
    assert_match t('user_mailer.new_match.chat_link'), chat_mail.html_part.decoded
    assert_match t('user_mailer.new_match.chat_link'), another_chat_mail.html_part.decoded
  end
end
