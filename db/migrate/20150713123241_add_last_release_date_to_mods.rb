class AddLastReleaseDateToMods < ActiveRecord::Migration
  def change
    add_reference :mods, :last_version, index: true
    add_column :mods, :last_release_date, :datetime, index: true
  end
end
