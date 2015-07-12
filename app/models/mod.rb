# AutoHtml.add_filter(:simple_format_fix).with({}) do |text, html_options|
#   require 'action_view'
#   # text_array = text.match(/<div.*<\/div>/)

#   ActionView::Base.new.simple_format(text, {class: 'p'}, sanitize: false, wrapper_tag: 'div' )
# end

class Mod < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  FORBIDDEN_NAMES = %q(new create edit update destroy)

  ### Relationships
  #################

  belongs_to :author, class_name: 'User'
  belongs_to :category, counter_cache: true
  belongs_to :game_version_start, class_name: 'GameVersion'
  belongs_to :game_version_end, class_name: 'GameVersion'
  belongs_to :forum_post

  has_many :downloads
  has_many :visits
  has_many :files, class_name: 'ModFile', dependent: :destroy
  has_many :versions, class_name: 'ModVersion', dependent: :destroy
  has_many :assets, ->{ order 'sort_order asc' }, class_name: 'ModAsset', dependent: :destroy
  has_many :tags
  has_many :favorites
  has_many :forum_posts

  has_many :mod_game_versions, -> { uniq }, dependent: :destroy
  has_many :game_versions, -> { uniq.sort_by_older_to_newer }, through: :mod_game_versions
  has_many :categories, through: :mods_categories

  # has_one :latest_version, -> { sort_by_newer_to_older.limit(1) }, class_name: 'ModVersion'
  # has_one :second_latest_version, -> { sort_by_newer_to_older.limit(1).offset(1) }, class_name: 'ModVersion'
  has_one :first_asset, -> { sort_by_older_to_newer.limit(1) }, class_name: 'ModAsset'

  accepts_nested_attributes_for :assets, allow_destroy: true
  accepts_nested_attributes_for :versions, allow_destroy: true
  accepts_nested_attributes_for :files, allow_destroy: true

  ### Scopes
  #################

  scope :filter_by_category, ->(category) { where(category: category) }
  scope :filter_by_game_version, ->(game_version) do
    select('DISTINCT mods.*').joins(:mod_game_versions).where(mod_game_versions: { game_version: game_version })
  end
  scope :sort_by_most_recent, -> { group('mod_versions.mod_id').includes(:versions).order('mod_versions.released_at desc') }
  scope :sort_by_alpha, -> { order('LOWER(mods.name) asc') }
  scope :sort_by_forum_comments, -> { order('mods.forum_comments_count desc') }
  scope :sort_by_downloads, -> { order('mods.downloads_count desc') }
  scope :sort_by_popular, -> { includes(:forum_post).order('forum_posts.views_count desc') }
  
  def self.filter_by_search_query(query)
    s1 = s2 = s3 = self

    s1 = s1.where 'mods.name LIKE ?', "%#{query}%"
    found_ids = s1.all.map(&:id)
    found_ids = s1.all.map(&:id)

    s2 = s2.where('mods.id NOT IN (?)', found_ids) if not found_ids.empty?
    s2 = s2.where 'mods.summary LIKE ?', "%#{query}%"
    found_ids = found_ids + s2.all.map(&:id)

    s3 = s3.where('mods.id NOT IN (?)', found_ids) if not found_ids.empty?
    s3 = s3.where 'mods.description LIKE ?',"%#{query}%"

    s1.all.concat s2.all.concat s3.all
  end

  ### Callbacks
  #################

  auto_html_for :description do
    redcarpet
    image
    youtube(autoplay: false)
    link rel: 'nofollow'
  end

  before_save do
    if forum_url
      self.forum_post = ForumPost.find_by_url(forum_url)
    end
  end

  after_save do
    if forum_post
      forum_post.mod = self
      forum_post.save
    end
  end

  ### Validations
  #################

  validate do
    manager = MediaLinks::Manager.new media_links_string
    if not manager.valid?
      self.errors[:media_links_string].push "Invalid media links: " + manager.invalid_urls.join(', ')
    end

    if manager.size > 6
      self.errors[:media_links_string].push "No more than 6 links please"
    end
  end

  validates :name, presence: true
  # validates :author, presence: true
  validates :category, presence: true

  # name uniqueness with link
  validate do
    if ( mod = Mod.where(name: name).first )
      if mod.id != id
        url = Rails.application.routes.url_helpers.category_mod_path mod.category, mod
        self.errors[:name].push I18n.t('activerecord.errors.models.mod.attributes.name.taken_with_link', url: url)
      end
    end
  end

  # Github URL
  validate do
    if github.present? and not extract_github_path(github)
      self.errors[:github].push I18n.t('activerecord.errors.models.mod.attributes.github.invalid')
    end
  end

  ### Attributes
  #################

  attr_accessor :media_links_string
  attr_accessor :imgur_url
  attr_accessor :imgur_thumbnail
  attr_accessor :imgur_normal
  alias_attribute :github_path, :github

  # serialize :media_links, MediaLinks::Manager

  # def media_links_string=(val)
  #   @media_links_string = val 
  #   self.media_links = MediaLinks::Manager.new val, [MediaLinks::Imgur]
  #   val
  # end

  # def media_links_string
  #   @media_links_string ||= self.media_links.to_string
  # end
  
  def imgur_url
    "http://imgur.com/#{imgur}"
  end
  
  def imgur_normal
    # Yeah, it could be something else than JPG, but Imgur doesn't care, they're cool
    "http://i.imgur.com/#{imgur}.jpg"
  end

  def imgur_thumbnail
    "http://i.imgur.com/#{imgur}b.jpg"
  end

  def latest_version
    versions[-1]
  end

  def second_latest_version
    versions[-2]
  end

  def game_versions_string
    read_attribute(:game_versions_string) || set_game_versions_string
  end

  def author_name
    if super.present?
      super
    else 
      author ? author.name : nil
    end
  end

  def github_url
    "http://github.com/#{github_path}"
    # github_url.match('[^/]+/[^/]+\/?\Z').to_s
  end

  def github=(val)
    write_attribute :github, extract_github_path(val) || val
  end

  def latest_mod_file_and_version(number = nil)
    result = []
    selected_versions = number ? versions.last(number) : versions
    selected_versions.reverse.each do |version|
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
