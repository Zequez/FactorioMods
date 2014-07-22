class AddSortOrderToModVersions < ActiveRecord::Migration
  def change
    add_column :mod_versions, :sort_order, :integer, null: false, default: 0
  end
end
