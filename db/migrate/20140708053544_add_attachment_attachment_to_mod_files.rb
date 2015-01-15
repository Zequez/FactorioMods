class AddAttachmentAttachmentToModFiles < ActiveRecord::Migration
  def self.up
    change_table :mod_files do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :mod_files, :attachment
  end
end
