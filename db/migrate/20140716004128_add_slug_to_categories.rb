class AddSlugToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :slug, :string, index: true, unique: true
  end
end
