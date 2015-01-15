class AddDescriptionToMods < ActiveRecord::Migration
  def change
    add_column :mods, :description, :text
  end
end
