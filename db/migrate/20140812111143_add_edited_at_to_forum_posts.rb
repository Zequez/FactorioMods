class AddEditedAtToForumPosts < ActiveRecord::Migration
  def change
    add_column :forum_posts, :edited_at, :datetime
  end
end
