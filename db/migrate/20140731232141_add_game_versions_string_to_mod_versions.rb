class AddGameVersionsStringToModVersions < ActiveRecord::Migration
  def change
    add_column :mod_versions, :game_versions_string, :string
  end
end
