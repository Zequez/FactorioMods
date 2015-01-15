class AddAttachmentImageToModAssets < ActiveRecord::Migration
  def self.up
    change_table :mod_assets do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :mod_assets, :image
  end
end
