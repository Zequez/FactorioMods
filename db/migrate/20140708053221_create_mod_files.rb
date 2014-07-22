class CreateModFiles < ActiveRecord::Migration
  def change
    create_table :mod_files do |t|
      t.string :name
      t.references :mod, index: true
      t.references :mod_version, index: true
      t.integer :downloads_count

      t.timestamps
    end
  end
end
