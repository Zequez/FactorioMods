class AddGameToGameVersions < ActiveRecord::Migration
  def change
    add_reference :game_versions, :game, index: true
  end
end
