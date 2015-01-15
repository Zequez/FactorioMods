class AddSortOrderToModAssets < ActiveRecord::Migration
  def change
    add_column :mod_assets, :sort_order, :integer, null: false, default: 0
  end
end
