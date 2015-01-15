class AddSummaryToMods < ActiveRecord::Migration
  def change
    add_column :mods, :summary, :string
  end
end
