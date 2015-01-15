class AddSortOrderToModFiles < ActiveRecord::Migration
  def change
    add_column :mod_files, :sort_order, :integer, null: false, default: 0
  end
end
