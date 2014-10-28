class AddForumSubforumUrlToMods < ActiveRecord::Migration
  def change
    add_column :mods, :forum_subforum_url, :string
  end
end
