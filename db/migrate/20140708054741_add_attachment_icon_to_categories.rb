class AddAttachmentIconToCategories < ActiveRecord::Migration
  def self.up
    change_table :categories do |t|
      t.attachment :icon
    end
  end

  def self.down
    drop_attached_file :categories, :icon
  end
end
