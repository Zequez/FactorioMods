class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :user, index: true
      t.references :mod, index: true
      t.datetime :created_at
    end
  end
end
