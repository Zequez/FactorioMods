class AddVisibleToMods < ActiveRecord::Migration
  def change
    add_column :mods, :visible, :boolean, default: true, null: false
  end
end
