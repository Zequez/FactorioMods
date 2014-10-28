class AddPreciseGameVersionStringToModVersions < ActiveRecord::Migration
  def change
    add_column :mod_versions, :precise_game_versions_string, :string
  end
end
