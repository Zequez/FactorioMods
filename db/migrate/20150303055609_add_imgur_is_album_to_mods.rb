class AddImgurIsAlbumToMods < ActiveRecord::Migration
  def change
    add_column :mods, :imgur_is_album, :boolean
  end
end
