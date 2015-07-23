class ForumPost < ActiveRecord::Base
  belongs_to :mod
  belongs_to :subforum, counter_cache: true

  scope :sort_by_newer_to_older, ->{ order('last_post_at desc') }
  scope :for_mod_creation, ->{ where(mod: nil, not_a_mod: false) }
  scope :for_mod_update, ->{ where(title_changed: true).where.not(mod: nil) }

  attr_accessor :content

  def markdown_content
    @markdown_content ||= ReverseMarkdown.convert content
  end

  def title=(val)
    self.title_changed = title_was != val
    super(val)
  end
end
