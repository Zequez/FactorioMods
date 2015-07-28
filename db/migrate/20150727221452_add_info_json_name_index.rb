class AddInfoJsonNameIndex < ActiveRecord::Migration
  def change
    add_index :mods, :info_json_name
  end
end
