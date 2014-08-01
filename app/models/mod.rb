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

  has_many :mod_game_versions
  has_many :game_versions, -> { uniq.sort_by_older_to_newer }, through: :mod_game_versions

  accepts_nested_attributes_for :assets, allow_destroy: true
  accepts_nested_attributes_for :versions, allow_destroy: true
  accepts_nested_attributes_for :files, allow_destroy: true

  alias_attribute :github_url, :github

  scope :in_category, ->(category) { where(category: category) }
  scope :for_game_version, ->(game_version) do
    joins(:mod_game_versions).where(mod_game_versions: { game_version: game_version })
  end
  scope :sort_by_most_recent, -> { order('mods.updated_at desc') }
  scope :sort_by_alpha, -> { order('mods.name asc') }
  scope :sort_by_forum_comments, -> { order('mods.forum_comments_count desc') }
  scope :sort_by_downloads, -> { order('mods.downloads_count desc') }

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
