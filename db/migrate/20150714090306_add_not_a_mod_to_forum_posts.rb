class AddNotAModToForumPosts < ActiveRecord::Migration
  def change
    add_column :forum_posts, :not_a_mod, :boolean, default: false
  end
end
