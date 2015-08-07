class AddAuthorToMods < ActiveRecord::Migration
  def change
    add_reference :mods, :author, index: true
  end
end
