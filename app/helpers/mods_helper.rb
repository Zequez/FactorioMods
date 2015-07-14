module ModsHelper
  def mod_date(date)
    if date
      string = time_ago_in_words(date) + ' ago'
      time_tag(date, string, title: date.to_s(:rfc822)).html_safe
    else
      ''
    end
  end

  def mod_release(mod_version)
    string = h mod_version.number
    string += (' (' + mod_date(mod_version.released_at) + ')').html_safe if mod_version.released_at
    string
  end

  def forum_post_stats_link
    link_to "#{@mod.forum_post.comments_count} comments / #{@mod.forum_post.views_count} views", @mod.forum_url
  end

  def attachment_label(mod, name)
    return nil if mod.attachment.blank?
    file_name = mod.send(:"#{name}_file_name")
    file_size = number_to_human_size(mod.send(:"#{name}_file_size"))

    "#{file_name} / #{file_size}"
  end

  def attachment_title(mod, name)
    return "File" if mod.attachment.blank?
    file_updated = time_ago_in_words(mod.send(:"#{name}_updated_at"))

    "File / #{file_updated} ago"
  end

  def mod_version_title(mod_version)
    return "Mod version" if mod_version.new_record?
    str = "Mod version"

    if mod_version.game_versions_string.present?
      str += "/ #{mod_version.game_versions_string}"
    end

    if mod_version.released_at
      time_ago = time_ago_in_words(mod_version.released_at)
      str += "/ #{time_ago} ago"
    end

    str
  end

  def category_tag_link(category)
    link_to category_filter_url(category), class: 'tag' do
      content_tag(:i, '', class: category.icon_class) + ' ' + category.name
    end
  end

  def link_to_file_url_with_name(file)
    if file.download_url.present?
      begin
        link_to URI(file.download_url).path.scan(/(?<=\/)[^\/]*\Z/).first, file.download_url
      rescue URI::InvalidURIError; end
    elsif file.attachment.present?
      link_to "#{file.attachment_file_name} (#{number_to_human_size(file.attachment_file_size)})", file.attachment.url
    end
  end
end
