class SetDefaultForumPostAndForumSubforumUrl < ActiveRecord::Migration
  def change
    change_column :mods, :forum_url, :string, default: '', null: false
    change_column :mods, :forum_subforum_url, :string, default: '', null: false
  end
end
