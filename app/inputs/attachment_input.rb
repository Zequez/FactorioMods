class AttachmentInput < Formtastic::Inputs::FileInput
  def image_html_options
    {:class => 'attachment'}.merge(options[:image_html] || {})
  end

  def to_html
    input_wrapping do
      label_html <<
      image_html <<
      name_html <<
      builder.file_field(method, input_html_options)
    end
  end

protected

  def image_html
    return ''.html_safe if builder.object.new_record? or options[:image].blank?


    url = case options[:image]
    when Symbol
      builder.object.send(method).send(:url, options[:image]) # Paperclip
    when Proc
      options[:image].call(builder.object)
    else
      options[:image].to_s
    end

    builder.template.image_tag(url, image_html_options).html_safe
  end

  def name_html
    return builder.object.send(method).original_filename
  end
end