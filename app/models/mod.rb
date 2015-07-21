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

  has_many :mod_game_versions, -> { uniq }, dependent: :destroy
  has_many :game_versions, -> { uniq.sort_by_older_to_newer }, through: :mod_game_versions
  has_many :categories, through: :categories_mods
  has_many :categories_mods, dependent: :destroy
  has_many :authors, through: :authors_mods, class_name: 'User'
  has_many :authors_mods, dependent: :destroy

  # has_one :latest_version, -> { sort_by_newer_to_older.limit(1) }, class_name: 'ModVersion'
  # has_one :second_latest_version, -> { sort_by_newer_to_older.limit(1).offset(1) }, class_name: 'ModVersion'

  accepts_nested_attributes_for :versions, allow_destroy: true
  accepts_nested_attributes_for :files, allow_destroy: true

  ### Scopes
  #################

  scope :filter_by_category, ->(category) { joins(:categories_mods).where(categories_mods: { category_id: category }) }
  scope :filter_by_game_version, ->(game_version) do
    joins(:mod_game_versions).where(mod_game_versions: { game_version: game_version })
  end
  scope :sort_by_most_recent, -> { order('mods.last_release_date desc NULLS LAST') }
  scope :sort_by_alpha, -> { order('LOWER(mods.name) asc') }
  scope :sort_by_forum_comments, -> { order('mods.forum_comments_count desc') }
  scope :sort_by_downloads, -> { order('mods.downloads_count desc') }
  scope :sort_by_popular, -> { includes(:forum_post).order('forum_posts.views_count desc NULLS LAST') }

  scope :filter_by_search_query, ->(query) do
    where('mods.name ILIKE ? OR mods.summary ILIKE ? OR mods.description ILIKE ?', "%#{query}%", "%#{query}%", "%#{query}%")
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

  ### Callbacks
  #################

  before_save do
    if forum_url_changed?
      self.forum_post = ForumPost.find_by_url(forum_url)
      # self.forum_posts << forum_post
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

  after_save do
    if author_id_changed?
      if author and not author.is_dev
        author.is_dev = true
        author.save
      end
    end
  end

  # find or generate users from #authors_list
  before_validation do
    if authors_list.present?
      authors_names = authors_list.split(',').map(&:strip)
      authors_index = User.where('lower(name) IN (?)', authors_names.map(&:downcase)).index_by{ |user| user.name.downcase }
      self.authors = authors_names.map{ |name| authors_index[name.downcase] || User.autogenerate(name) }
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

  ### Validations
  #################

  validates :name, presence: true, length: { maximum: 50  }
  validates :categories, presence: true
  validates :official_url, allow_blank: true, format: { with: /\Ahttps?:\/\/.*\Z/ }
  validates :license_url, allow_blank: true, format: { with: /\Ahttps?:\/\/.*\Z/ }
  validates :forum_url, allow_blank: true, format: { with: /\Ahttps?:\/\/.*\Z/ }
  validates :summary, length: { maximum: 1000 }
  validates :slug, uniqueness: true

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

  def latest_version
    versions[0]
  end

  def second_latest_version
    versions[1]
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

  def latest_versions_with_files(number = nil)
    result = []
    selected_versions = number ? versions.last(number) : versions
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

  def has_versions?
    versions.size > 0
  end

  def has_files?
    files.size > 0
  end

  def slug=(val)
    super(val.present? ? val : nil)
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
