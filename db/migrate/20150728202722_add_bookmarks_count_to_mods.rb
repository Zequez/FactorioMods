class AddBookmarksCountToMods < ActiveRecord::Migration
  def change
    add_column :mods, :bookmarks_count, :integer, null: false, default: 0
  end
end
