class CreateModGameVersions < ActiveRecord::Migration
  def change
    create_table :mod_game_versions do |t|
      t.references :game_version, index: true
      t.references :mod_version, index: true
      t.references :mod, index: true
    end
  end
end
