module ModsHelper
  def mod_date(date)
    if date
      string = time_ago_in_words(date) + ' ago'
      time_tag(date, string, title: date.to_s(:rfc822)).html_safe
    else
      ''
    end
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

  def link_to_file_url_with_name(file)
    if file.download_url.present?
      begin
        if file.attachment.present?
          link_to(file.attachment_file_name, file.download_url) + ' (' + link_to('Mirror', file.attachment.url) + ')'
        else
          link_to URI(file.download_url).path.scan(/(?<=\/)[^\/]*\Z/).first, file.download_url
        end
      rescue URI::InvalidURIError; end
    elsif file.attachment.present?
      link_to "#{file.attachment_file_name} (#{number_to_human_size(file.attachment_file_size)})", file.attachment.url
    end
  end

  def index_title
    if current_page? '/'
      title t('.title.root')
    else
      title_append t('.title.version', version: @game_version.number) if @game_version
      title_append t('.title.mods')
      title_append t('.title.category', category: @category.name) if @category
      title_append t(".title.sort.#{@sort}") if @sort
      title
    end
  end
end
