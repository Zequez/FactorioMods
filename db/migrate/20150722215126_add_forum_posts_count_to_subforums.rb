class AddForumPostsCountToSubforums < ActiveRecord::Migration
  def change
    add_column :subforums, :forum_posts_count, :integer
  end
end
