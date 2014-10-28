class AddTitleChangedToForumPosts < ActiveRecord::Migration
  def change
    add_column :forum_posts, :title_changed, :boolean
  end
end
