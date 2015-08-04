class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :slug
      t.string :name, default: '', null: false
      t.string :github_name, default: '', null: false
      t.string :forum_name, default: '', null: false
      t.integer :mods_count, default: 0, null: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
