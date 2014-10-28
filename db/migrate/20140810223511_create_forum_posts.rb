class CreateForumPosts < ActiveRecord::Migration
  def change
    create_table :forum_posts do |t|
      t.integer :comments_count, default: 0, null: false
      t.integer :views_count, default: 0, null: false
      t.datetime :published_at
      t.datetime :last_post_at
      t.string :url
      t.string :title
      t.string :author_name

      t.timestamps
    end
  end
end
