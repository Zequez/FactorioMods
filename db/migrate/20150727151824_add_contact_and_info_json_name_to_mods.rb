class AddContactAndInfoJsonNameToMods < ActiveRecord::Migration
  def change
    add_column :mods, :contact, :string, default: '', null: false
    add_column :mods, :info_json_name, :string, default: '', null: false
  end
end
