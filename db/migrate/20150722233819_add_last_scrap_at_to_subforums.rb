class AddLastScrapAtToSubforums < ActiveRecord::Migration
  def change
    add_column :subforums, :last_scrap_at, :datetime
  end
end
