module ApplicationHelper
  def login_layout
    @login_layout = true
  end

  def login_layout?
    @login_layout
  end

  def landing_layout
    @landing_layout = true
  end

  def landing_layout?
    @landing_layout
  end

  def breadcrumb(list = {})
    @breadcrumb = { I18n.t('dashboard') => (list.present? ? root_path : nil) }.merge list
  end

  def find_breadcrumb_list
    @breadcrumb || []
  end

  def meta_tags(h)
    content_for(:meta_tags) do
      h.map do |key, value|
        "<meta property='#{key}' content='#{value}'/>"
      end.join.html_safe
    end
  end
end
