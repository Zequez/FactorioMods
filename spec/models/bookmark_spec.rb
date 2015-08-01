describe Bookmark, type: :model do
  subject(:bookmark){ create :bookmark }

  it { is_expected.to respond_to :user }
  it { expect(bookmark.build_user).to be_kind_of User }
  it { is_expected.to respond_to :mod }
  it { expect(bookmark.build_mod).to be_kind_of Mod }

  describe 'validation' do
    it 'should be invalid without a mod' do
      expect(build(:bookmark, mod: nil)).to be_invalid
    end

    it 'should be invalid without a user' do
      expect(build(:bookmark, user: nil)).to be_invalid
    end

    it 'should be valid with a user and a mod' do
      user = create :user
      mod = create :mod
      expect(build(:bookmark, mod: mod, user: user)).to be_valid
    end

    it 'should be invalid if the mod and the user already have a bookmark' do
      user = create :user
      mod = create :mod
      create :bookmark, mod: mod, user: user
      expect(build(:bookmark, mod: mod, user: user)).to be_invalid
    end
  end
end
