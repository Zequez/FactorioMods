class MultiAuthorsUpdate < ActiveRecord::Migration
  def up
    MultiAuthorsUpdater.new.update
  end
end
