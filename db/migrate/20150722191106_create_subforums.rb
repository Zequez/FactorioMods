class CreateSubforums < ActiveRecord::Migration
  def change
    create_table :subforums do |t|
      t.string :url
      t.string :name, default: '', null: false
      t.references :game_version, index: true
      t.boolean :scrap
    end
  end
end
