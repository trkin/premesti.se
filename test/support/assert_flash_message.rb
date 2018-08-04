module MiniTest::Assertions
  def assert_select_alert_message(text)
    assert_select 'div#alert-debug', text
  end

  def assert_select_notice_message(text)
    assert_select 'div#notice-debug', text
  end
end
