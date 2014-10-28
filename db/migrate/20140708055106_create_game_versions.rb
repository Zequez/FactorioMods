class CreateGameVersions < ActiveRecord::Migration
  def change
    create_table :game_versions do |t|
      t.string :number
      t.datetime :released_at

      t.timestamps
    end
  end
end
