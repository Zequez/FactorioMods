class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.references :mod, index: true
      t.string :ip
      t.datetime :created_at
    end
  end
end
