# AutoHtml.add_filter(:simple_format_fix).with({}) do |text, html_options|
#   require 'action_view'
#   # text_array = text.match(/<div.*<\/div>/)

#   ActionView::Base.new.simple_format(text, {class: 'p'}, sanitize: false, wrapper_tag: 'div' )
# end

class Mod < ActiveRecord::Base
  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :name,
      [:name, 'by', :author_name]
    ]
  end

  IMGUR_IMAGE_URLS = [
    %r{\Ahttps?://imgur\.com/(\w+)\Z},
    %r{\Ahttps?://i\.imgur\.com/(\w+)\.(\w+)\Z}
  ]

  ### Relationships
  #################

  belongs_to :author, class_name: 'User' # Deprecated
  belongs_to :owner, class_name: 'User', foreign_key: :author_id
  belongs_to :game_version_start, class_name: 'GameVersion'
  belongs_to :game_version_end, class_name: 'GameVersion'
  belongs_to :forum_post
  belongs_to :last_version, class_name: 'ModVersion'

  # has_many :downloads
  # has_many :visits
  has_many :files, class_name: 'ModFile', dependent: :destroy
  has_many :versions, -> { most_recent }, class_name: 'ModVersion', dependent: :destroy, inverse_of: :mod
  # has_many :tags
  has_many :favorites
  has_many :forum_posts
  has_many :bookmarks

  has_many :mod_game_versions, -> { uniq }, dependent: :destroy
  has_many :game_versions, -> { uniq.sort_by_older_to_newer }, through: :mod_game_versions
  has_many :categories, through: :categories_mods
  has_many :categories_mods, dependent: :destroy
  has_many :authors, ->{ includes(:authors_mods).order('authors_mods.sort_order') } , through: :authors_mods, class_name: 'User'
  has_many :authors_mods, dependent: :destroy

  # has_one :latest_version, -> { sort_by_newer_to_older.limit(1) }, class_name: 'ModVersion'
  # has_one :second_latest_version, -> { sort_by_newer_to_older.limit(1).offset(1) }, class_name: 'ModVersion'

  accepts_nested_attributes_for :versions, allow_destroy: true
  accepts_nested_attributes_for :files, allow_destroy: true

  ### Scopes
  #################

  scope :visible, ->{ where(visible: true) }

  scope :sort_by, ->(sort_type) do
    @sorted_by = sort_type.to_sym
    case sort_type.to_sym
    when :alpha then sort_by_alpha
    when :most_recent then sort_by_most_recent
    when :popular then sort_by_popular
    when :forum_comments then sort_by_forum_comments
    when :downloads then sort_by_downloads
    else
      @sorted_by = :alpha
      sort_by_alpha
    end
  end
  scope :sort_by_most_recent, -> { order('mods.last_release_date desc NULLS LAST') }
  scope :sort_by_alpha, -> { order('LOWER(mods.name) asc') }
  scope :sort_by_forum_comments, -> { order('mods.forum_comments_count desc') }
  scope :sort_by_downloads, -> { order('mods.downloads_count desc') }
  scope :sort_by_popular, -> { includes(:forum_post).order('forum_posts.views_count desc NULLS LAST') }

  scope :filter_by_category, ->(category) do
    @uncategorized = all
    if category.present?
      @category = category.is_a?(String) ? Category.find(category) : category
      joins(:categories_mods).where(categories_mods: { category: @category })
    end
  end

  scope :filter_by_game_version, ->(gv) do
    if gv.present?
      @game_version = gv.is_a?(String) ? GameVersion.find_by_number!(gv) : gv
      joins(:mod_game_versions).where(mod_game_versions: { game_version: @game_version })
    end
  end

  scope :filter_by_search_query, ->(query) do
    if query.present?
      query = query[0..30]
      where('mods.name ILIKE ? OR mods.summary ILIKE ? OR mods.description ILIKE ?', "%#{query}%", "%#{query}%", "%#{query}%")
    end
  end

  scope :filter_by_names, ->(names_list) do
    if names_list.present?
      names = names_list.split(',').map(&:strip)
      where(info_json_name: names)
    end
  end

  # def self.filter_by_search_query(query)
  #   s1 = s2 = s3 = self

  #   s1 = s1.where 'mods.name LIKE ?', "%#{query}%"
  #   found_ids = s1.all.map(&:id)

  #   s2 = s2.where('mods.id NOT IN (?)', found_ids) if not found_ids.empty?
  #   s2 = s2.where 'mods.summary LIKE ?', "%#{query}%"
  #   found_ids = found_ids + s2.all.map(&:id)

  #   s3 = s3.where('mods.id NOT IN (?)', found_ids) if not found_ids.empty?
  #   s3 = s3.where 'mods.description LIKE ?',"%#{query}%"

  #   s1.all.concat s2.all.concat s3.all
  # end

  ### Collection attributes
  #################

  class << self
    attr_reader :game_version, :category, :uncategorized, :sorted_by
  end

  ### Builders
  #################

  def self.new_for_form(user, forum_post_id)
    user = nil if user.is_admin?
    mod = Mod.new owner: user, visible: true
    mod_version = mod.versions.build
    mod_version.files.build

    if forum_post_id
      forum_post = ForumPost.find forum_post_id
      mod.name = forum_post.title

      mod.authors_list = forum_post.author_name
      mod.forum_url = forum_post.url

      if forum_post.published_at
        mod_version.released_at = forum_post.published_at
      end

      if forum_post.subforum and forum_post.subforum.game_version
        mod_version.game_versions = [forum_post.subforum.game_version]
      end
    end

    mod
  end

  ### Callbacks
  #################

  before_save do
    if forum_url_changed? and not forum_post_id_changed?
      if forum_url.present?
        self.forum_post = ForumPost.find_by_url(forum_url)
      else
        self.forum_post = nil
      end
    end
  end

  before_save do
    if author
      self.author_name = author.name
    end
  end

  after_save do
    if forum_post
      forum_post.mod = self
      forum_post.save
    end
  end

  # find or generate users from #authors_list
  before_validation do
    if authors_list.present?
      authors_names = authors_list.split(',').map(&:strip).reject(&:blank?).take(10).uniq(&:downcase)
      authors_index = User.where('lower(name) IN (?)', authors_names.map(&:downcase)).index_by{ |user| user.name.downcase }
      self.authors = @reordered_authors = authors_names.each_with_index.map do |name, i|
        authors_index[name.downcase] || User.autogenerate(name: name)
      end
    end
  end

  # add the #authors errors to #authors_list
  after_validation do
    if authors_list.present?
      authors.each do |author|
        author.errors[:name].each do |error|
          self.errors[:authors_list].push(author.name + ' ' + error)
        end
      end

      # We can't do this because errors[:authors] also holds
      # the individual authors errors without any information
      # about the user
      # errors[:authors_list].concat errors[:authors]
    end
  end

  # Set the #sort_order of the #authors_mods
  # We cannot use self.authors because it you cannot change
  # the order of the association
  after_save do
    if @reordered_authors
      @reordered_authors.each_with_index do |author, i|
        authors_mods.where(author: author).update_all(sort_order: i)
      end
    end
  end

  ### Validations
  #################

  validates :name, presence: true, length: { maximum: 50  }
  validates :categories, presence: true
  validates :official_url, allow_blank: true, format: { with: /\Ahttps?:\/\/.*\Z/ }
  validates :license_url, allow_blank: true, format: { with: /\Ahttps?:\/\/.*\Z/ }
  validates :forum_url, allow_blank: true, format: { with: /\Ahttps?:\/\/.*\Z/ }
  validates :summary, length: { maximum: 1000 }
  validates :slug, uniqueness: true
  validates :info_json_name, presence: true # we shouldn't validate uniqueness though

  # #categories.count limit
  validate do
    if categories.size > 8
      errors[:categories].push I18n.t('activerecord.errors.models.mod.attributes.categories.too_many')
    end
  end

  # #authors.count limit
  validate do
    if authors.size > 8
      error_msg = I18n.t('activerecord.errors.models.mod.attributes.authors.too_many')
      errors[:authors].push error_msg
      errors[:authors_list].push error_msg if authors_list.present?
    end
  end

  # Github URL
  validate do
    if github.present? and not extract_github_path(github)
      self.errors[:github].push I18n.t('activerecord.errors.models.mod.attributes.github.invalid')
    end
  end

  # Imgur
  validate do
    if extract_imgur_id(imgur) == false
      self.errors[:imgur].push I18n.t('activerecord.errors.models.mod.attributes.imgur.invalid')
    end
  end

  ### Attributes
  #################

  attr_accessor :imgur_url
  attr_accessor :imgur_thumbnail
  attr_accessor :imgur_normal
  attr_accessor :authors_list
  alias_attribute :github_path, :github
  alias_attribute :subforum_url, :forum_subforum_url

  def imgur=(val)
    imgur_id = extract_imgur_id(val)
    if imgur_id == false
      write_attribute(:imgur, val)
    else
      write_attribute(:imgur, imgur_id)
    end
  end

  def extract_imgur_id(val)
    if val =~ /\A[A-Z0-9]+\Z/i or val.blank?
      val
    else
      match = IMGUR_IMAGE_URLS.map{|reg| match = reg.match(val) }.compact.first
      match ? match[1] : false
    end
  end

  def imgur_url
    "http://imgur.com/#{imgur}"
  end

  def imgur(size = false)
    return nil if self[:imgur].blank?
    return self[:imgur] unless size
    case size
    when :normal then imgur_normal
    when :thumbnail then imgur_thumbnail
    when :large_thumbnail then imgur_large_thumbnail
    else
      super
    end
  end

  def imgur_normal
    # Yeah, it could be something else than JPG, but Imgur doesn't care, they're cool
    "http://i.imgur.com/#{imgur}.jpg"
  end

  def imgur_thumbnail
    "http://i.imgur.com/#{imgur}b.jpg"
  end

  def imgur_large_thumbnail
    "http://i.imgur.com/#{imgur}l.jpg"
  end

  def game_versions_string
    read_attribute(:game_versions_string) || set_game_versions_string
  end

  def author_name
    return super if super.present?
    return author.name if author
  end

  def github_url
    "http://github.com/#{github_path}" if github_path
  end

  def github=(val)
    write_attribute :github, extract_github_path(val) || val
  end

  def slug=(val)
    super(val.present? ? val : nil)
  end

  def authors_list
    @authors_list ||= authors.map(&:name).join(', ')
  end

  # We should eventually rename the mod attributes to match the ones in the API,
  # we use these different attributes to roughly match the ones used in
  # the mods info.json files
  def as_json(options = {})
    selected_versions = options[:versions] ? [options[:versions]].flatten : versions
    {
      title: name,
      name: info_json_name,
      url: Rails.application.routes.url_helpers.mod_url(self), # Eww
      description: summary,
      homepage: official_url,
      contact: contact,
      authors: authors.map(&:name),
      releases: selected_versions.map do |version|
        {
          version: version.number,
          released_at: version.released_at,
          game_versions: version.game_versions_string.split('-'), # Ideally we should load the #game_versions
          dependencies: [],
          files: version.files.map do |file|
            {
              name: file.name,
              url: file.download_url,
              mirror: file.attachment.present? ? file.attachment.url : ''
            }
          end
        }
      end
    }
  end

  private

  def set_game_versions_string
    gvs = begin
      last_game_version = game_versions.last
      first_game_version = game_versions.first
      if not last_game_version and not first_game_version
        ''
      elsif last_game_version == first_game_version
        first_game_version.number
      else
        "#{first_game_version.number}-#{last_game_version.number}"
      end
    end

    update_column :game_versions_string, gvs
    self.game_versions_string = gvs
  end

  def extract_github_path(val)
    uri = URI(val)
    if uri.host == 'github.com' or uri.host == nil
      path = uri.path.gsub(/^\/|\/$/, '')
      if path.scan('/').size == 1
        path
      else
        nil
      end
    else
      nil
    end
  end
end
