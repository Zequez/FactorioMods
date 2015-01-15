class ConvertModsForumCommentsCountToInteger < ActiveRecord::Migration
  def change
    change_column :mods, :forum_comments_count, :integer
  end
end
