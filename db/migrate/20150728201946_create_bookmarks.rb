class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.references :mod, index: true
      t.references :user, index: true
    end
  end
end
