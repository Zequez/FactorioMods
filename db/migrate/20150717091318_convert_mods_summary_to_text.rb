class ConvertModsSummaryToText < ActiveRecord::Migration
  def change
    change_column :mods, :summary, :text
  end
end
