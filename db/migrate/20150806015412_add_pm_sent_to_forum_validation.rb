class AddPmSentToForumValidation < ActiveRecord::Migration
  def change
    add_column :forum_validations, :pm_sent, :boolean, null: false, default: false
  end
end
