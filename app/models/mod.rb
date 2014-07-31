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
  has_many :assets, class_name: 'ModAsset'
  has_many :tags
  has_many :favorites

  accepts_nested_attributes_for :assets, allow_destroy: true
  accepts_nested_attributes_for :versions, allow_destroy: true
  accepts_nested_attributes_for :files, allow_destroy: true

  alias_attribute :github_url, :github

  scope :in_category, ->(category) { where(category: category) }
  scope :for_game_version, ->(game_version) do
    rsa = joins('INNER JOIN game_versions gvs ON gvs.id = mods.game_version_start_id')
    .joins('INNER JOIN game_versions gve ON gve.id = mods.game_version_end_id')
    .where('gvs.sort_order <= ? AND gve.sort_order >= ?', game_version.sort_order, game_version.sort_order)
    puts rsa.to_sql
    rsa
    # where(versions: { game_version: game_version })
  end
  scope :sort_by_most_recent, -> { order('updated_at desc') }
  scope :sort_by_alpha, -> { order('name asc') }
  scope :sort_by_forum_comments, -> { order('forum_comments_count desc') }
  scope :sort_by_downloads, -> { order('downloads_count desc') }

  after_save :get_game_version_from_mod_versions

  def get_game_version_from_mod_versions
    sorted_versions = versions.sort_by_older_to_newer
    first_version = sorted_versions.first
    last_version = sorted_versions.last
    self.game_version_start = first_version.game_version_start if first_version
    self.game_version_end = last_version.game_version_end || last_version.game_version_start if last_version
    self.game_version_end = first_version.game_version_start if not last_version and first_version
    update_columns(game_version_start_id: game_version_start_id, game_version_end_id: game_version_end_id)
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
end
