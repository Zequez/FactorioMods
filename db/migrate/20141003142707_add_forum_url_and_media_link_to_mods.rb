class AddForumUrlAndMediaLinkToMods < ActiveRecord::Migration
  def change
    add_column :mods, :forum_url, :string
    add_column :mods, :media_links, :text
  end
end
