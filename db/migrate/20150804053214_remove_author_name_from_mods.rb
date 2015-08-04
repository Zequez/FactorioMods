class RemoveAuthorNameFromMods < ActiveRecord::Migration
  def change
    remove_column :mods, :author_name
  end
end
