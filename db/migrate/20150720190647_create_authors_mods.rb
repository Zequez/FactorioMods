class CreateAuthorsMods < ActiveRecord::Migration
  def change
    create_table :authors_mods do |t|
      t.references :mod, index: true
      t.references :author, index: true
      t.integer :sort_order, default: 0, null: false
    end
  end
end
