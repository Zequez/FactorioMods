class CreateSearchTerms < ActiveRecord::Migration
  def change
    create_table :search_terms do |t|
      t.string :query
      t.string :ip
      t.datetime :created_at
    end
  end
end
