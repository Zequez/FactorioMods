class AddGameVersionStartAndGameVersionEndToMods < ActiveRecord::Migration
  def change
    add_reference :mods, :game_version_start, index: true
    add_reference :mods, :game_version_end, index: true
  end
end
