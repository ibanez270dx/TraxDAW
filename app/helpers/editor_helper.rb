module EditorHelper

  def switch_icon(name, options={})
    options = { name: name }.merge(options)
    content_tag(:div, class: "switch-icon #{options[:name]}") do 
      check_box_tag("#{options[:name]}-on") +
      label_tag("#{options[:name]}-on") { content_tag(:i, nil, class: "icon-#{name} inset") }
    end
  end

end
