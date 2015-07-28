class Bookmark < ActiveRecord::Base
  belongs_to :mod, counter_cache: :bookmarks_count
  belongs_to :user
end
