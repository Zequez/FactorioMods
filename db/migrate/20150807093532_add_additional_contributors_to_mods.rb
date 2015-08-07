class AddAdditionalContributorsToMods < ActiveRecord::Migration
  def change
    add_column :mods, :additional_contributors, :string, default: '', null: false
  end
end
