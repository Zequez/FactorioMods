class MakeUserNameUnique < ActiveRecord::Migration
  def change
    add_index :users, :name, unique: true
    add_index :users, :slug, unique: true
  end
end
