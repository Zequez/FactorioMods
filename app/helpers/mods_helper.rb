module ModsHelper
  def mod_date(date)
    if date
      string = time_ago_in_words(date) + ' ago'
      content_tag :span, string, title: date.to_s(:rfc822)
    else
      ''
    end
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

    "File / #{file_updated}"
  end

  def mod_version_title(mod_version)
    return "Mod version" if mod_version.new_record?
    time_ago = time_ago_in_words(mod_version.released_at)
    "Mod version / #{mod_version.game_versions_string} / #{time_ago} ago"
  end
end
