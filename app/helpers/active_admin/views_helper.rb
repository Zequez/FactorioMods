module ActiveAdmin::ViewsHelper
  def toggler_status_tag(url, value)
    content = link_to((value ? 'YES→NO' : 'NO→YES'), url,
      method: :put,
      'data-type' => :json,
      remote: true).html_safe

    content_tag(:span, content, class: "toggler_status_tag status_tag #{value ? 'yes' : 'no'}")
  end
end