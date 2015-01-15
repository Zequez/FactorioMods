class AddIconClassToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :icon_class, :string
  end
end
