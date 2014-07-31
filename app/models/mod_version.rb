class ModVersion < ActiveRecord::Base
  belongs_to :game_version_start, class_name: 'GameVersion'
  belongs_to :game_version_end, class_name: 'GameVersion'
  belongs_to :mod

  scope :sort_by_older_to_newer, -> { order('sort_order asc') }
  scope :sort_by_newer_to_older, -> { order('sort_order desc') }
  scope :get_by_game_version_start, -> { joins(:game_version_start).order('game_versions.sort_order asc') }
  scope :get_by_game_version_end, -> { joins(:game_version_end).order('game_versions.sort_order asc') }

  validate :validate_existance_of_game_versions

  def validate_existance_of_game_versions
    unless (game_version_start_id and GameVersion.find_by_id(game_version_start_id)) or
           (game_version_end_id   and GameVersion.find_by_id(game_version_end_id))
      errors[:game_version_start] << 'Must select a game version'
    end
  end

  before_save :remove_redundant_game_versions

  def remove_redundant_game_versions
    if game_version_end
      if (game_version_start == game_version_end) or
         (game_version_end.group_id and game_version_end.group_id == game_version_start_id)
        self.game_version_end = nil
      elsif (not game_version_start) or (game_version_start > game_version_end)
        self.game_version_start, self.game_version_end = game_version_end, game_version_start
      end
    end
  end

  def to_label
    number
  end
end
