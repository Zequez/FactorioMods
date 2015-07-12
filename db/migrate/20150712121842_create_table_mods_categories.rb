class CreateTableModsCategories < ActiveRecord::Migration
  def change
    create_table :table_mods_categories do |t|
      t.references :mod, index: true
      t.references :category, index: true
    end
  end
end
