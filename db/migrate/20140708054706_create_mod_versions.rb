class CreateModVersions < ActiveRecord::Migration
  def change
    create_table :mod_versions do |t|
      t.references :mod, index: true
      t.string :number
      t.references :game_version, index: true
      t.datetime :released_at

      t.timestamp
    end
  end
end
