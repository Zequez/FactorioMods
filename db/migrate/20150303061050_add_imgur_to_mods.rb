class AddImgurToMods < ActiveRecord::Migration
  def change
    add_column :mods, :imgur, :string
    remove_column :mods, :imgur_extension
    remove_column :mods, :imgur_id
    remove_column :mods, :imgur_is_album
  end
end
