class AddForumNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :forum_name, :string, default: '', null: false
  end
end
