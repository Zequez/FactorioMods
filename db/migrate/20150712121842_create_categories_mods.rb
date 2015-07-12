class CreateCategoriesMods < ActiveRecord::Migration
  def change
    create_table :categories_mods do |t|
      t.references :mod, index: true
      t.references :category, index: true
    end
  end
end
