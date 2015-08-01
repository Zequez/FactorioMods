describe ForumPost, :type => :model do
  subject(:post) { create :forum_post }

  it { is_expected.to respond_to :comments_count }
  it { is_expected.to respond_to :views_count }
  it { is_expected.to respond_to :published_at }
  it { is_expected.to respond_to :edited_at }
  it { is_expected.to respond_to :last_post_at }
  it { is_expected.to respond_to :url }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :author_name }
  it { is_expected.to respond_to :post_number }
  it { is_expected.to respond_to :title_changed }
  it { is_expected.to respond_to :not_a_mod }
  it { is_expected.to respond_to :subforum }
  it { expect(post.build_subforum).to be_kind_of Subforum }
  it { is_expected.to respond_to :mod }
  it { expect(post.build_mod).to be_kind_of Mod }

  describe '#title_changed' do
    it 'should be set to true if the title changed' do
      forum_post = create :forum_post, title: '[0.12] Super Mod (0.0.1)'
      expect(forum_post.title_changed).to eq true
      forum_post.title_changed = false
      forum_post.save!
      forum_post.title = '[0.12] Super Mod (0.0.2)'
      expect(forum_post.title_changed).to eq true
      forum_post.title = '[0.12] Super Mod (0.0.1)'
      expect(forum_post.title_changed).to eq false
      forum_post.title = '[0.12] Super Mod (0.0.2)'
      expect(forum_post.title_changed).to eq true
      forum_post.save!
      forum_post.reload
      expect(forum_post.title_changed).to eq true
    end
  end
end
