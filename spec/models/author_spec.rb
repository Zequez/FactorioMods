describe Author do
  subject(:author) { create :author }

  it { is_expected.to respond_to :slug }
  it { is_expected.to respond_to :name }
  it { is_expected.to respond_to :github_name }
  it { is_expected.to respond_to :forum_name }
  it { is_expected.to respond_to :mods_count }
  it { is_expected.to respond_to :user_id }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  it { is_expected.to respond_to :user }
  it { is_expected.to respond_to :authors_mods }
  it { is_expected.to respond_to :mods }

  its('build_user') { is_expected.to be_kind_of User }
  its('authors_mods.build') { is_expected.to be_kind_of AuthorsMod }
  its('mods.build') { is_expected.to be_kind_of Mod }

  describe 'attributes' do
    describe '#slug' do
      it 'should be the name but downcased, spaces removed, and the accents unaccented' do
        author = create :author, name: 'PoTa Tooó 123_44 Tucutuc'
        expect(author.slug).to eq 'pota-tooo-123_44-tucutuc'
      end
    end
  end

  describe 'validations' do
    it 'should not allow 2 users with the same #slug and it should add the error to #name too' do
      create :author, name: 'PoTa Tooó 123_44 Tucutuc'
      author2 = build :author, name: 'PoTa-Tooo 123_44 Tucutuc'
      expect(author2).to be_invalid
      expect(author2.errors[:slug]).to_not be_empty
      expect(author2.errors[:name]).to_not be_empty
    end

    it 'should not allow 2 users with the same Forum Name' do
      create :author, forum_name: 'rsarsa'
      expect(build :author, forum_name: 'rsarsa').to be_invalid
    end

    it 'should not allow an empty #name' do
      author = build :author, name: ''
      expect(author).to be_invalid
      expect(author.errors[:name]).to_not be_empty
    end

    it 'should not allow an empty string #name' do
      author = build :author, name: '        '
      expect(author).to be_invalid
      expect(author.errors[:name]).to_not be_empty
    end

    it 'the name should have at least a letter' do
      author = build :author, name: '-0-0-'
      expect(author).to be_invalid
      expect(author.errors[:name]).to_not be_empty
    end

    it 'the name should have at least a letter' do
      author = build :author, name: '-0-a-0-'
      expect(author).to be_valid
      expect(author.errors[:name]).to be_empty
    end
  end

  describe 'scopes and finders' do
    describe '#find_by_slugged_name' do
      it 'should by slug by slugging the query first' do
        author = create :author, name: '  PoTa Tooó     123_44 Tucutuc       '
        expect(Author.find_by_slugged_name('pota-tooo 123_44 Tucutúc')).to eq author
      end
    end
  end
end
