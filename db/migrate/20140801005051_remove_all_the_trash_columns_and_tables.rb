class RemoveAllTheTrashColumnsAndTables < ActiveRecord::Migration
  def change
    drop_table :game_version_groups
    remove_column :game_versions, :group_id, :is_group
    remove_column :mod_versions, :game_version_start_id
    remove_column :mod_versions, :game_version_end_id
    remove_column :mod_versions, :game_version
    remove_column :mod_versions, :game_version_id
    remove_column :mods, :game_version_start_id
    remove_column :mods, :game_version_end_id
  end
end
