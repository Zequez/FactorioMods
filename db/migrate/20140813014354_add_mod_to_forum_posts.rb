class AddModToForumPosts < ActiveRecord::Migration
  def change
    add_reference :forum_posts, :mod, index: true
  end
end
