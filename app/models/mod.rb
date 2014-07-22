class Mod < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  belongs_to :author, class_name: 'User'
  belongs_to :category, counter_cache: true

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
  scope :sort_by_most_recent, -> { order('updated_at desc') }
  scope :sort_by_alpha, -> { order('name asc') }
  scope :sort_by_forum_comments, -> { order('forum_comments_count desc') }
  scope :sort_by_downloads, -> { order('downloads_count desc') }

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
