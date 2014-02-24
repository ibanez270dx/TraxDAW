module EditorHelper

  def switch_icon(name)
    content_tag(:div, class: 'switch-icon') do 
      check_box_tag("#{name}-on") +
      label_tag("#{name}-on") { content_tag(:i, nil, class: "icon-#{name}") }
    end
  end

end
