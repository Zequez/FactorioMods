class AddNumberToSubforums < ActiveRecord::Migration
  def change
    add_column :subforums, :number, :integer
  end
end
