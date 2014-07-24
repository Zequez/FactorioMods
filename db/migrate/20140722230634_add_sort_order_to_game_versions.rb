class AddSortOrderToGameVersions < ActiveRecord::Migration
  def change
    add_column :game_versions, :sort_order, :integer, null: false, default: 0
  end
end
