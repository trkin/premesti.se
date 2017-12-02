class MyFormBuilder < BootstrapForm::FormBuilder
  def select(method, choices = nil, options = {}, html_options = {}, &block)
    options[:prompt] ||= I18n.t('please_select')
    super
  end
end
