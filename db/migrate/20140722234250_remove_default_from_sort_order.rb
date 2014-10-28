class RemoveDefaultFromSortOrder < ActiveRecord::Migration
  def change
    change_column :game_versions, :sort_order, :integer, null: true, default: nil
  end
end
