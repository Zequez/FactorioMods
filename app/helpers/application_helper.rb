module ApplicationHelper
  def filter_params
    @filter_params ||= begin
      filter_params_array = [:v, :q]
      filter_params = params.select{ |k,v| filter_params_array.include? k.to_sym }
      filter_params
    end
  end

  def category_probabilistic_count(category)
    if @mods.all_count != @mods.uncategorized_count
      aproximate_count = (category.mods_count.to_f / @mods.all_count * @mods.uncategorized_count).round(1).to_s
      content_tag('span', "~#{aproximate_count}", title: 'Probabilistic quantity').html_safe
    else
      category.mods_count
    end
  end

  def date_time_tag(date)
    if date
      string = time_ago_in_words(date) + ' ago'
      time_tag(date, string, title: date.to_s(:rfc822)).html_safe
    else
      ''
    end
  end

  def release_info(mod_version)
    string = h mod_version.number
    string += (' (' + date_time_tag(mod_version.released_at) + ')').html_safe if mod_version.released_at
    string
  end

  ### Misc helpers:
  ####################

  def missing_img(size, img_tag_options = {})
    img_tag_options = img_tag_options.reverse_merge({
      src: missing_img_url(size),
      title: t('helpers.no_image_available')
    })
    tag :img, img_tag_options
  end

  def missing_img_url(size)
    root_path + "images/missing_#{size}.png"
  end

  def body_controller_classes
    controller_path = params[:controller].split('/')
    controller_path.each_index.map{|i| controller_path[0..i].join('-')} << params[:action]
  end

  ### Content helpers:
  ####################

  def title(page_title = nil, options = {suffix: true})
    @title ||= ''
    @title = page_title.to_s + @title unless page_title.nil?
    @title = @title + t('layouts.application.title.suffix') if options[:suffix]
    @title = @title.strip
    content_for :title, @title[0].upcase + @title[1..-1]
  end

  def title_append(page_title_section)
    @title ||= ''
    @title = page_title_section.to_s + @title
  end

  def content_layout(type = nil) # :wide / :slim / :none
    if type and not [:wide, :slim, :none].include?(type)
      raise "#{type} given, :wide, :slim, or :none available"
    end
    @content_layout ||= type || :slim
  end

  ### Urls helpers:
  ####################

  def sort_url(sort)
    polymorphic_path([sort, (@category if params[:action] == 'index'), :mods], filter_params)
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

  ### Links helpers
  ####################

  def sort_link(sort, &block)
    url = sort.is_a?(Symbol) ? sort_url(sort) : sort
    link_to url, class: sort_active_class(sort), &block
  end

  def category_link(category, &block)
    link_to category_filter_url(category), class: category_filter_active_class(category), &block
  end

  def version_filter_option(version, &block)
    content_tag :option,
                t('.for_game_version', version: version.number),
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
    equal_to = sort.is_a?(Symbol) ? @sort : request.path
    (sort == equal_to) ? 'active' : nil
  end

  def category_filter_active_class(category)
    (@category == category) ? 'active' : nil
  end

  def version_filter_selected_state(version)
    (@game_version == version) ? 'selected' : nil
  end
end
