class AddGameVersionToModVersions < ActiveRecord::Migration
  def change
    add_column :mod_versions, :game_version, :string
  end
end
