class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.references :mod_file, index: true
      t.string :ip
      t.datetime :created_at
    end
  end
end
