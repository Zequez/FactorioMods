class CreateGameVersionGroups < ActiveRecord::Migration
  def change
    create_table :game_version_groups do |t|
      t.string :number

      t.timestamps
    end
  end
end
