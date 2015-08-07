class RenameModsAuthorIdToOwnerId < ActiveRecord::Migration
  def change
    rename_column :mods, :author_id, :owner_id
  end
end
