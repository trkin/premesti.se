require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'set locale' do
    get '/'
    assert_equal I18n.locale, I18n.default_locale

    host! 'sr.localhost'
    get '/'
    assert_equal I18n.locale, :sr
  end
end
