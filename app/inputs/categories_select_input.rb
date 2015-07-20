class CategoriesSelectInput < Formtastic::Inputs::SelectInput
  def select_html
    # Can a hack be horrible if it does something beautiful?
    # Changing the option generation script involves getting down the rabbit hole
    # down to actionview/lib/action_view/helpers/tags/select.rb
    # This is quick, dirty and easy
    # It basically adds the Formtastic class to the <select> <option>s, it works on Webkit.

    # t1 = Time.now
    custom_collection = raw_collection.map { |c| ["|#{c.icon_class}| #{c.name}", c.id] }
    result2 = builder.select(input_name, custom_collection, input_options, input_html_options)
    .gsub(/>\|([^|]*)\|/, ' class="\1">').html_safe
    # t2 = Time.now

    # icons = Hash[raw_collection.map{ |c| [c.id.to_s, "#{c.id}\" class=\"#{c.icon_class}"] }]
    # result1 = super.gsub(/(?<=value=")(\d+)(?=">)/, icons).html_safe

    # t3 = Time.now

    # L (t2 - t1)
    # L (t3 - t2)

    # result2
  end
end