class ConvertModVersionDatetimeToDate < ActiveRecord::Migration
  def change
    change_column :mod_versions, :released_at, :date
  end
end
