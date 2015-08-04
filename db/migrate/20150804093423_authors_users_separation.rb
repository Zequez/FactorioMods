class AuthorsUsersSeparation < ActiveRecord::Migration
  def change
    AuthorsUsersSeparationUpdater.new.run
  end
end
