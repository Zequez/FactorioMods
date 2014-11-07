class ConvertModReleasedAtDateToDatetime < ActiveRecord::Migration
  def change
    change_column :mod_versions, :released_at, :datetime
  end
end
