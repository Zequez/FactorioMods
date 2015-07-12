class AddImgurExtensionToMods < ActiveRecord::Migration
  def change
    add_column :mods, :imgur_extension, :string
  end
end
