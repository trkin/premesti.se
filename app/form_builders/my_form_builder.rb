class MyFormBuilder < BootstrapForm::FormBuilder
  def select(method, choices = nil, options = {}, html_options = {}, &block)
    if options.delete :label_as_prompt
      options[:prompt] = form_group_placeholder(options, method)
    else
      options[:prompt] ||= I18n.t('please_select')
    end
    super
  end
end
