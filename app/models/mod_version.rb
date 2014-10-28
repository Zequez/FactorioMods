class ModVersion < ActiveRecord::Base
  belongs_to :mod

  has_many :files, class_name: 'ModFile'
  has_many :mod_game_versions
  has_many :game_versions, through: :mod_game_versions

  scope :sort_by_older_to_newer, -> { order('sort_order asc') }
  scope :sort_by_newer_to_older, -> { order('sort_order desc') }

  accepts_nested_attributes_for :files, allow_destroy: true

  def game_versions_string
    if precise_game_versions_string.blank?
      read_attribute(:game_versions_string) || set_game_versions_string
    else
      precise_game_versions_string
    end
  end

  def to_label
    number
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
