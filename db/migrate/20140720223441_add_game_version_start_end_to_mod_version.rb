class AddGameVersionStartEndToModVersion < ActiveRecord::Migration
  def change
    add_reference :mod_versions, :game_version_start, index: true
    add_reference :mod_versions, :game_version_end, index: true
    remove_column :mod_versions, :game_version
  end
end
