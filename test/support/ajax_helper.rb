module AjaxHelper
  # select2 select is hidden so we need to click to trigger ajax
  # note that it is outside of your form, so don't use `within`
  # for non ajax select2 use as usual `select text, from: '#id'`
  def select2_ajax(li_text, text:, selector: 'label')
    find(selector, text: text).click
    find('li', text: li_text).click
  end
end

class ActionDispatch::SystemTestCase
  include AjaxHelper
end
