class ActionDispatch::IntegrationTest
  # assert_flash_message
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
