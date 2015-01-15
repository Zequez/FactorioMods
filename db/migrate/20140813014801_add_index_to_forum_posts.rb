class AddIndexToForumPosts < ActiveRecord::Migration
  def change
    add_index :forum_posts, :post_number
  end
end
