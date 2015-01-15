class AddForumPostToMods < ActiveRecord::Migration
  def change
    add_reference :mods, :forum_post, index: true
  end
end
