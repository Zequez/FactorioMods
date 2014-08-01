class AddGameVersionsStringToMod < ActiveRecord::Migration
  def change
    add_column :mods, :game_versions_string, :string
  end
end
