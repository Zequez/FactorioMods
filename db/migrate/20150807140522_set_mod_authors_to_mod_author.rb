class SetModAuthorsToModAuthor < ActiveRecord::Migration
  def change
    Mod.all.each do |mod|
      # Not really related, but this was pending from another previous migration
      mod.info_json_name = mod.slug if mod.info_json_name.blank?

      # We don't really have more than 1 author for each mod on production
      # Well, I think we have 1, but it's not worth it to make something more complex
      mod.author = mod.authors.first
      mod.save!
    end
  end
end
