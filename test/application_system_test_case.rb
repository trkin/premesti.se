require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemLoginHelpers
  include TranslateHelper

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def take_failed_screenshot
    false
  end

  def assert_alert_message(text)
    assert_selector 'div#alert-debug', text, visible: false
  end

  def assert_notice_message(text)
    assert_selector 'div#notice-debug', text, visible: false
  end
end
