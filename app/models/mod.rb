AutoHtml.add_filter(:simple_format_fix).with({}) do |text, html_options|
  require 'action_view'
  # text_array = text.match(/<div.*<\/div>/)

  ActionView::Base.new.simple_format(text, {class: 'p'}, sanitize: false, wrapper_tag: 'div' )

end

class Mod < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  belongs_to :author, class_name: 'User'
  belongs_to :category, counter_cache: true
  belongs_to :game_version_start, class_name: 'GameVersion'
  belongs_to :game_version_end, class_name: 'GameVersion'

  has_many :downloads
  has_many :visits
  has_many :files, class_name: 'ModFile'
  has_many :versions, class_name: 'ModVersion'
  has_many :assets, ->{ order 'sort_order asc' }, class_name: 'ModAsset'
  has_many :tags
  has_many :favorites

  has_many :mod_game_versions, -> { uniq }
  has_many :game_versions, -> { uniq.sort_by_older_to_newer }, through: :mod_game_versions

  # has_one :latest_version, -> { sort_by_newer_to_older.limit(1) }, class_name: 'ModVersion'
  # has_one :second_latest_version, -> { sort_by_newer_to_older.limit(1).offset(1) }, class_name: 'ModVersion'
  has_one :first_asset, -> { sort_by_older_to_newer.limit(1) }, class_name: 'ModAsset'

  accepts_nested_attributes_for :assets, allow_destroy: true
  accepts_nested_attributes_for :versions, allow_destroy: true
  accepts_nested_attributes_for :files, allow_destroy: true

  alias_attribute :github_url, :github

  scope :filter_by_category, ->(category) { where(category: category) }
  scope :filter_by_game_version, ->(game_version) do
    select('DISTINCT mods.*').joins(:mod_game_versions).where(mod_game_versions: { game_version: game_version })
  end
  scope :sort_by_most_recent, -> { group('mod_versions.mod_id').joins(:versions).order('mod_versions.released_at desc') }
  scope :sort_by_alpha, -> { order('mods.name asc') }
  scope :sort_by_forum_comments, -> { order('mods.forum_comments_count desc') }
  scope :sort_by_downloads, -> { order('mods.downloads_count desc') }
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


    # where "mods.name LIKE ? OR mods.summary LIKE ? OR mods.description LIKE ?",
    #       "%#{query}%",
    #       "%#{query}%",
    #       "%#{query}%"
  end

  # def self.preload_latest_and_second_latest_versions(mods)
  #   ids = mods.map(&:id)
  #   mod_versions = ModVersion.select('DISTINCT mod_id').sort_by_newer_to_older.find_by_mod_id(ids)
  #   mod_versions.each do
  # end

  ### Calbacks
  ###############

  auto_html_for :description do
    html_escape
    image
    youtube(autoplay: false)
    link rel: 'nofollow'
    simple_format
  end

  ### Attributes
  ###############

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
    if author
      author.name
    else
      read_attribute :author_name
    end
  end

  def github_path
    github_url.match('[^/]+/[^/]+\Z').to_s
  end

  def latest_mod_file_and_version(number)
    result = []
    versions.last(number).reverse.each do |version|
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
end
