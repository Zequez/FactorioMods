class ChangeAuthorsSlugToBeUnique < ActiveRecord::Migration
  def change
    change_column :authors, :slug, :string, unique: true
    add_index :authors, :slug
  end
end
