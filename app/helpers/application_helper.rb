module ApplicationHelper
  def filter_params
    @filter_params ||= begin
      filter_params_array = [:v, :q]
      filter_params = params.select{ |k,v| filter_params_array.include? k.to_sym }
      filter_params
    end
  end

  def all_categories_mods_count
    @categories.map(&:mods_count).reduce(&:+)
  end

  ### Misc helpers:
  ####################

  def mod_asset_missing_image(size)
    @empty_asset ||= ModAsset.new
    @empty_asset.image.url(size)
  end

  def if_na(condition, result = nil, &block)
    if !result and block_given?
      condition ? capture(&block) : 'N/A'
    else
      condition ? result : 'N/A'
    end
  end

  ### Content helpers:
  ####################

  def title(page_title = nil, options = {suffix: true})
    @title ||= ''
    @title = page_title.to_s + @title unless page_title.nil?
    @title = @title + t('title.suffix') if options[:suffix]
    @title = @title.strip
    content_for :title, @title[0].upcase + @title[1..-1]
  end

  def title_append(page_title_section)
    @title ||= ''
    @title = page_title_section.to_s + @title
  end

  ### Urls helpers:
  ####################

  def sort_url(sort)
    polymorphic_path([sort, @category, :mods], filter_params)
  end

  def category_filter_url(category)
    polymorphic_path([@sort, category, :mods], filter_params)
  end

  def version_filter_url(version)
    version_number = version ? version.number : nil
    polymorphic_path([@sort, @category, :mods], filter_params.merge(v: version_number))
  end

  def search_form_url
    polymorphic_path([@sort, @category, :mods])
  end

  def search_filter_url(query)
    polymorphic_path([@sort, @category, :mods], filter_params.merge(q: query))
  end

  def edit_mod_url(mod)
    edit_category_mod_url(mod.category, mod)
  end

  ### Links helpers
  ####################

  def sort_link(sort, &block)
    link_to sort_url(sort), class: sort_active_class(sort), &block
  end

  def category_link(category, &block)
    link_to category_filter_url(category), class: category_filter_active_class(category), &block
  end

  def version_filter_option(version, &block)
    content_tag :option,
                "For Factorio v#{version.number}",
                value: version_filter_url(version),
                selected: version_filter_selected_state(version)
  end

  def search_form(&block)
    content_tag(:form, action: search_form_url, method: 'get') do
      tag(:input, type: 'hidden', name: :v, value: params[:v]) +
      capture(&block)
    end
  end

  ### Active state helpers
  ####################

  def sort_active_class(sort)
    (@sort == sort) ? 'active' : nil
  end

  def category_filter_active_class(category)
    (@category == category) ? 'active' : nil
  end

  def version_filter_selected_state(version)
    (@game_version == version) ? 'selected' : nil
  end
end
