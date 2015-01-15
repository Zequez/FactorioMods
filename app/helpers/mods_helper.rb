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

  def attachment_label(mod, name)
    return nil if mod.new_record?
    file_name = mod.send(:"#{name}_file_name")
    file_size = number_to_human_size(mod.send(:"#{name}_file_size"))
    
    "#{file_name} / #{file_size}"
  end

  def attachment_title(mod, name)
    return "File" if mod.new_record?
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

  def mod_category_link(mod)
    link_to [mod.category, :mods] do
      content_tag(:i, '', class: mod.category.icon_class) + ' ' + mod.category.name
    end
  end
end
