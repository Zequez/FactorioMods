class ForumPost < ActiveRecord::Base
  belongs_to :mod

  scope :sort_by_newer_to_older, ->{ order('last_post_at desc') }
  scope :title_changed, ->{ where title_changed: true }
  scope :without_mod, ->{ where mod: nil }
  scope :with_mod, ->{ where.not mod: nil }

  attr_accessor :content

  def markdown_content
    @markdown_content ||= ReverseMarkdown.convert content
  end
end
