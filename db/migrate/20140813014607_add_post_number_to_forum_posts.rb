class AddPostNumberToForumPosts < ActiveRecord::Migration
  def change
    add_column :forum_posts, :post_number, :integer
  end
end
