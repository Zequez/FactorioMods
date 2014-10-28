class AddGroupIdToGameVersions < ActiveRecord::Migration
  def change
    add_column :game_versions, :group_id, :integer
  end
end
