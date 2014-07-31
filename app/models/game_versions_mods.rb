class GameVersionsMods < ActiveRecord::Base
  belongs_to :game_version
  belongs_to :mods
end
