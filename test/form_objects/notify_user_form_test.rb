require 'test_helper'
class LandingSinupTest < ActiveSupport::TestCase
  test 'ignore same tag' do
    user = create :user
    create :email_message, user: user, tag: 'old_tag'
    assert_performed_jobs 1, only: ActionMailer::DeliveryJob do
      NotifyUserForm.new(subject: 'Hi', message: 'Bye', user_id: nil, tag: 'new_tag').perform
    end
    assert_performed_jobs 0, only: ActionMailer::DeliveryJob do
      NotifyUserForm.new(subject: 'Hi', message: 'Bye', user_id: nil, tag: 'new_tag').perform
    end
    assert_performed_jobs 0, only: ActionMailer::DeliveryJob do
      NotifyUserForm.new(subject: 'Hi', message: 'Bye', user_id: nil, tag: 'old_tag').perform
    end
  end

  test 'ignore unsubscribed' do
    user = create :user
    create :user, subscribe_to_news_mailing_list: false
    create :user, subscribe_to_news_mailing_list: false
    assert_performed_jobs 3, only: ActionMailer::DeliveryJob do
      result = NotifyUserForm.new(subject: 'Hi', message: 'Byye', user_id: nil).perform
      assert result.success?
      mail1, mail2, mail3 = give_me_all_mail_and_clear_mails
      assert_match user.email, mail1.html_part.decoded
      puts '2'
      assert_nil mail2
      puts '3'
      assert_nil mail3
    end
  end
end
