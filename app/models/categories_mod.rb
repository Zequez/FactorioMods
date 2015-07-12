class CategoriesMod < ActiveRecord::Base
  belongs_to :category, counter_cache: :mods_count
  belongs_to :mod
end