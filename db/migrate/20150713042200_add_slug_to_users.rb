class AddSlugToUsers < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string, index: true, unique: true
  end
end
