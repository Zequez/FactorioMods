class RangeSliderInput < Formtastic::Inputs::SliderInput
  def to_html
    input_wrapping do
      label_html <<
      name_html <<
      builder.file_field(method, input_html_options)
    end
  end
end