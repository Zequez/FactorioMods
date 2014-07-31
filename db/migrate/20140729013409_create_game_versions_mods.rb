class CreateGameVersionsMods < ActiveRecord::Migration
  def change
    create_table :game_versions_mods do |t|
      t.references :game_version, index: true
      t.references :mods, index: true
    end
  end
end