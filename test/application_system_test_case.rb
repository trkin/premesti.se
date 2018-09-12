require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include TranslateHelper

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def take_failed_screenshot
    false
  end
end
