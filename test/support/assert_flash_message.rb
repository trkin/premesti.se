class ActionDispatch::IntegrationTest
  # assert_flash_message with full sentence:
  #   assert_notice_message t('user_canceled_account')
  # or partial match with regexp:
  #   assert_alert_message Regexp.new t('errors.messages.blank')
  def assert_alert_message(text)
    assert_select 'div#alert-debug', text
  end

  def assert_notice_message(text)
    assert_select 'div#notice-debug', text
  end

  def assert_select_field_error(text)
    assert_select 'div.invalid-feedback', text
  end
end
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def assert_alert_message(text)
    assert_selector 'div#alert-debug', text, visible: false
  end

  def assert_notice_message(text)
    assert_selector 'div#notice-debug', text, visible: false
  end
end
