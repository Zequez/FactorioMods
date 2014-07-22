class CreateMods < ActiveRecord::Migration
  def change
    create_table :mods do |t|
      t.string :name
      t.references :author, index: true
      t.string :author_name
      t.datetime :first_version_date
      t.datetime :last_version_date
      t.string :github
      t.integer :favorites_count
      t.integer :comments_count
      t.string :license
      t.string :license_url
      t.string :official_url
      t.string :forum_post_url
      t.string :forum_comments_count
      t.integer :downloads_count
      t.integer :visits_count
      t.references :category, index: true
      t.timestamps
    end
  end
end
