class MultiDatalistInput < Formtastic::Inputs::DatalistInput
  include Formtastic::Inputs::Base::Placeholder

  def input_html_options
    {
      separator: @options[:separator] || ','
    }.merge(super)
  end
end