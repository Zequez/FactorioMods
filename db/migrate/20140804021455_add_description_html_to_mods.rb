class AddDescriptionHtmlToMods < ActiveRecord::Migration
  def change
    add_column :mods, :description_html, :text
  end
end
