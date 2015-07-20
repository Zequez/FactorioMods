class MakeModSlugUnique < ActiveRecord::Migration
  def change
    add_index :mods, :slug, unique: true
  end
end
