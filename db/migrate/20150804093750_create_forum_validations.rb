class CreateForumValidations < ActiveRecord::Migration
  def change
    create_table :forum_validations do |t|
      t.references :user, index: true
      t.references :author, index: true
      t.string :vid, index: true
      t.boolean :validated, default: false

      t.timestamps
    end
  end
end
