require 'rails_helper'

RSpec.describe ForumPost, :type => :model do
  subject(:post) { create :forum_post }

  it { expect(post).to respond_to :comments_count }
  it { expect(post).to respond_to :views_count }
  it { expect(post).to respond_to :published_at }
  it { expect(post).to respond_to :edited_at }
  it { expect(post).to respond_to :last_post_at }
  it { expect(post).to respond_to :url }
  it { expect(post).to respond_to :title }
  it { expect(post).to respond_to :author_name }
  it { expect(post).to respond_to :post_number }
  it { expect(post).to respond_to :title_changed }

  it { expect(post).to respond_to :mod }
  it { expect(post.build_mod).to be_kind_of Mod }
  # TODO: Should belong_to modd
end
