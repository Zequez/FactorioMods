class ForumPost < ActiveRecord::Base
  belongs_to :mod

  scope :sort_by_newer_to_older, ->{ order('last_post_at desc') }
  scope :title_changed, ->{ where title_changed: true }
end
