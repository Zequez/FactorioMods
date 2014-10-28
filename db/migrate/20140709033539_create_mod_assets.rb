class CreateModAssets < ActiveRecord::Migration
  def change
    create_table :mod_assets do |t|
      t.references :mod, index: true
      t.references :mod_version, index: true
      t.string :video_url

      t.timestamps
    end
  end
end
