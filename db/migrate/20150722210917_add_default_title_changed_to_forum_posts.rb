class AddDefaultTitleChangedToForumPosts < ActiveRecord::Migration
  def change
    change_column :forum_posts, :title_changed, :boolean, default: true, null: false
  end
end
