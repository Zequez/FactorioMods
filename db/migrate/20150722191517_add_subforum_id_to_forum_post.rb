class AddSubforumIdToForumPost < ActiveRecord::Migration
  def change
    add_reference :forum_posts, :subforum, index: true
  end
end
