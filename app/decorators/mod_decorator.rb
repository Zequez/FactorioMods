class ModDecorator < Draper::Decorator
  delegate :id, :name, :forum_url, :subforum_url

  def authors_count; mod.authors.size end

  def game_versions_string
    return na if mod.game_versions_string.blank?
    "v" + mod.game_versions_string
  end

  def forum_link_title
    if mod.subforum_url.present?
      h.t('mods.decorator.forum_link_title.subforum')
    elsif mod.forum_post
      h.t('mods.decorator.forum_link_title.detailed', views: forum_views, comments: forum_comments)
    else
      h.t('mods.decorator.forum_link_title.vague')
    end
  end

  def forum_link(length = :short) # or :long
    if mod.subforum_url.present?
      subforum_link = h.link_to h.t('mods.decorator.forum_link.subforum.subforum'), mod.subforum_url
      if mod.forum_url.present?
        post_link = h.link_to h.t('mods.decorator.forum_link.subforum.post'), mod.forum_url
        (subforum_link + ' - ' + post_link).html_safe
      else
        subforum_link
      end
    elsif mod.forum_post
      text = h.t("mods.decorator.forum_link.#{length}", views: forum_views, comments: forum_comments).html_safe
      h.link_to text, mod.forum_post.url
    elsif mod.forum_url.present?
      h.link_to h.t("mods.decorator.forum_link.vague.#{length}"), mod.forum_url
    else
      na
    end
  end

  def last_version_date
    return na unless last_version_date_available?
    last_version.released_at.to_s(:rfc822)
  end

  def last_version_date_time_tag
    return na unless last_version_date_available?
    h.date_time_tag(last_version.released_at)
  end

  def first_version_date_time_tag
    return na unless last_version_date_available?
    h.date_time_tag(last_version.released_at)
  end

  def authors_links_list
    return na if mod.authors.empty?

    mod.authors.map do |author, i|
      link = h.link_to(author.name, author)
      if author.user_id == mod.author_id and mod.authors.size > 1
        maintainer = h.t('helpers.mods.maintainer')
        link + " (#{maintainer})"
      else
        link
      end
    end.join(', ').html_safe
  end

  def categories_links
    mod.categories.map{ |cat| category_tag_link(cat) }.join.html_safe
  end

  def img(size)
    h.tag :img,
      src: img_url(size),
      title: (h.t('helpers.no_image_available') if !mod.imgur)
  end

  def img_link(size = :large_thumbnail)
    if ( url = mod.imgur(:normal) )
      h.link_to img(size), url
    else
      img(size) # Image missing
    end
  end

  def bookmark_link
    if h.current_user
      bookmarked = h.current_user.has_bookmarked_mod?(mod)
      path = h.bookmarks_path(bookmark: { mod_id: mod.id })
      h.content_tag :span, class: ['mods-bookmark', ('bookmarked' if bookmarked)] do
        h.link_to(
          h.icon('star-o'), path,
          class: 'mods-bookmark-create',
          method: :post,
          remote: true
        ) +
        h.link_to(
          h.icon('star'), path,
          class: 'mods-bookmark-destroy',
          method: :delete,
          remote: true
        )
      end
    else

    end
  end

  def title_link
    h.link_to(mod.name, mod)
  end

  def edit_link
    if h.can? :edit, mod
      h.link_to h.t('mods.decorator.edit_mod'), [:edit, mod], class: 'edit-link'
    end
  end

  def pretty_summary
    h.simple_format mod.summary
  end

  def first_release_info
    return na unless mod.versions.first
    h.release_info(mod.versions.first)
  end

  def last_release_info
    return na unless mod.versions.last
    h.release_info(mod.versions.last)
  end

  def github_link
    return na unless mod.github.present?
    h.link_to mod.github_url, mod.github_url
  end

  def forum_iframe_title
    text = if mod.subforum_url.present?
      h.t('.mod_subforum')
    else
      h.t('.mod_forum_post')
    end

    (text + ' ' + forum_link(:long)).html_safe
  end

  def preferred_forum_url
    mod.subforum_url.presence || mod.forum_url
  end

  def visibility_notice
    if not mod.visible?
      if h.current_user and h.current_user.is_admin?
        h.t('mods.show.non_visible.admin')
      elsif h.current_user and h.current_user.is_dev?
        h.t('mods.show.non_visible.dev')
      else
        h.t('mods.show.non_visible.non_dev')
      end
    end
  end

  def install_protocol_url(version = nil)
    json_mod = ModSerializer.new(mod, versions: (version ? [version] : nil)).to_json
    'factoriomods://' + Base64.strict_encode64(json_mod).to_s
  end

  ### Download button
  ###################

  def last_version_has_downloads?
    last_version and last_version.has_files?
  end

  def first_available_download_url
    last_version.files.first.available_url
  end

  def download_files(number = nil)
    result = []
    selected_versions = number ? mod.versions.last(number) : mod.versions
    selected_versions.each do |version|
      version.files.each do |file|
        if block_given?
          yield version, file
        else
          result << [version, file]
        end
      end
    end
    result
  end

  def more_downloads_link(number = nil)
    if mod.versions.size > number
      h.content_tag :li, h.link_to(h.t('mods.decorator.more_versions'), h.mod_path(mod, anchor: 'download'))
    end
  end

  def has_versions?
    mod.versions.size > 0
  end

  def has_files?
    mod.files.size > 0
  end

  ### Private helpers
  ###################

  private

  def last_version
    mod.versions[0]
  end

  def forum_views
    mod.forum_post.views_count
  end

  def forum_comments
    mod.forum_post.comments_count
  end

  def na
    @na ||= h.t('helpers.not_available')
  end

  def last_version_date_available?
    last_version.present? and last_version.released_at.present?
  end

  def category_tag_link(category)
    h.link_to h.category_filter_url(category), class: 'tag' do
      h.content_tag(:i, '', class: category.icon_class) + ' ' + category.name
    end
  end

  def img_url(size)
    mod.imgur(size).presence || h.missing_img_url(size)
  end
end
