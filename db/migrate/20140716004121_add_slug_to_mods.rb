class AddSlugToMods < ActiveRecord::Migration
  def change
    add_column :mods, :slug, :string, index: true, unique: true
  end
end
