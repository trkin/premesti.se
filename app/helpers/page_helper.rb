module PageHelper
  def help_icon(text)
    content_tag :i, nil, class: 'fa fa-info-circle', title: text
  end
end
