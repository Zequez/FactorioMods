class Bookmark < ActiveRecord::Base
  belongs_to :mod, counter_cache: :bookmarks_count
  belongs_to :user

  validates :mod, presence: true
  validates :user, presence: true

  # Validates that the user and mod don't already have an bookmark
  validate do
    if Bookmark.exists?(user: user, mod: mod)
      errors.add :base, 'Mod already bookmarked'
    end
  end
end
