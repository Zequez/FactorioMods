class AddDownloadUrlToModFile < ActiveRecord::Migration
  def change
    add_column :mod_files, :download_url, :string
  end
end
