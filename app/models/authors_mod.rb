class AuthorsMod < ActiveRecord::Base
  belongs_to :mod
  belongs_to :author, counter_cache: :mods_count
end
