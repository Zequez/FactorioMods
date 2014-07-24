class AddIsGroupToGameVersions < ActiveRecord::Migration
  def change
    add_column :game_versions, :is_group, :boolean, null: false, default: false
  end
end
