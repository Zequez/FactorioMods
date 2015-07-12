class AddImgurAlbumIdToMod < ActiveRecord::Migration
  def change
    add_column :mods, :imgur_id, :string
  end
end
