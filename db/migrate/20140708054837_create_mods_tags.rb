class CreateModsTags < ActiveRecord::Migration
  def change
    create_table :mods_tags do |t|
      t.references :mod, index: true
      t.references :tag, index: true
      t.datetime :created_at
    end
  end
end
