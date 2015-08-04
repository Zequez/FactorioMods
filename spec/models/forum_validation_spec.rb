describe ForumValidation, type: :model do
  subject(:forum_validation) { create :forum_validation }

  it { is_expected.to respond_to :vid }
  it { is_expected.to respond_to :validated }
  its(:validated) { is_expected.to eq false }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }

  it { is_expected.to respond_to :user }
  it { is_expected.to respond_to :author }

  its(:build_user) { is_expected.to be_kind_of User }
  its(:build_author) { is_expected.to be_kind_of Author }

  describe 'validations' do
    it 'should be invalid without an #user' do
      fv = build :forum_validation, user: nil
      expect(fv).to be_invalid
    end

    it 'should be invalid without an #author' do
      fv = build :forum_validation, author: nil
      expect(fv).to be_invalid
    end
  end

  describe '#vid' do
    it 'should be a long string after saving' do
      fv = create :forum_validation
      expect(fv.vid).to match(/\A[a-z0-9]{50}\Z/)
    end
  end

  describe '#associate_user_and_author!' do
    it 'should associate the user and author' do
      user = create :user
      author = create :author
      fv = create :forum_validation, user: user, author: author
      fv.associate_user_and_author!
      expect(user.author).to eq author
      expect(author.user).to eq user
      expect(fv.validated).to eq true
    end
  end

  # describe '#send_pm' do
  #   def send_pm
  #     VCR.use_cassette('forum_validation', record: :new_episodes) do
  #       subject.send_pm
  #     end
  #   end
  #
  #   it 'should authenticate and send a PM in the forum' do
  #
  #   end
  # end
end
