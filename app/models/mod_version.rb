class ModVersion < ActiveRecord::Base
  belongs_to :game_version_start, class_name: 'GameVersion'
  belongs_to :game_version_end, class_name: 'GameVersion'

  before_save :generate_game_version

  def generate_game_version
    # self.game_version = game_version_start.range_string(game_version_end)
  end

  def to_label
    number
  end
end
