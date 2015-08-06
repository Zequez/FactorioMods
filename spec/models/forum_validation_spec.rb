describe ForumValidation, type: :model do
  # We force-clean the persistant bot
  before(:each) { ForumValidation.instance_variable_set :@bot, nil }
  after(:each) { ForumValidation.instance_variable_set :@bot, nil }

  subject(:forum_validation) { create :forum_validation }

  it { is_expected.to respond_to :vid }
  it { is_expected.to respond_to :validated }
  its(:validated) { is_expected.to eq false }
  it { is_expected.to respond_to :created_at }
  it { is_expected.to respond_to :updated_at }
  it { is_expected.to respond_to :pm_sent }
  its(:pm_sent) { is_expected.to eq false }

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

  describe '#send_pm' do
    before :each do
      @u = create :user, name: 'Potato'
      @a = create :author, name: 'Salatto', forum_name: 'Salatto' # Italian salad
      @fv = create :forum_validation, user: @u, author: @a
      @m1 = create :mod, authors: [@a], owner: nil, name: 'lalalalalalalala'
      @m2 = create :mod, authors: [@a], owner: nil, name: 'lelelelelelelele'
    end

    it 'should create a new forum bot if not logged in' do
      bot = double('ForumBot')
      expect(ForumBot).to receive(:new).once.and_return(bot)

      expect(bot).to receive(:authenticated?).and_return false
      expect(bot).to receive(:authenticate).with(ENV['FORUM_BOT_ACCOUNT'], ENV['FORUM_BOT_PASSWORD']).and_return true
      expect(bot).to receive(:get_user_id).with('Salatto').and_return(1234)
      expect(bot).to receive(:send_pm)
        .with(1234, /validation/, %r{/forum-validations/#{@fv.id}/validate\?vid=#{@fv.vid}.*lelelelelelelele.*lalalalalalalala}m)
        .and_return(true)

      expect(@fv.send_pm).to eq true
      expect(@fv.pm_sent?).to eq true
    end

    it 'should use the same instance for multiple forum validations' do
      bot = double('ForumBot')
      expect(ForumBot).to receive(:new).once.and_return(bot)

      expect(bot).to receive(:authenticated?).and_return false
      expect(bot).to receive(:authenticate).with(ENV['FORUM_BOT_ACCOUNT'], ENV['FORUM_BOT_PASSWORD']).and_return true
      expect(bot).to receive(:get_user_id).twice.with('Salatto').and_return(1234)
      expect(bot).to receive(:send_pm).twice
        .with(1234, /validation/, %r{/forum-validations/#{@fv.id}/validate\?vid=#{@fv.vid}.*lelelelelelelele.*lalalalalalalala}m)
        .and_return(true)

      expect(@fv.send_pm).to eq true
      expect(@fv.pm_sent?).to eq true
      @fv = ForumValidation.first

      expect(bot).to receive(:authenticated?).and_return true

      expect(@fv.send_pm).to eq true
      expect(@fv.pm_sent?).to eq true
    end

    it "should return false if the author wasn't found" do
      bot = double('ForumBot')
      expect(ForumBot).to receive(:new).once.and_return(bot)
      expect(bot).to receive(:authenticated?).and_return false
      expect(bot).to receive(:authenticate).with(ENV['FORUM_BOT_ACCOUNT'], ENV['FORUM_BOT_PASSWORD']).and_return true
      expect(bot).to receive(:get_user_id).with('Salatto').and_return(nil)

      expect(@fv.send_pm).to eq false
      expect(@fv.pm_sent?).to eq false
    end

    it 'should return false if sending the PM fails for unknown reasons' do
      bot = double('ForumBot')
      expect(ForumBot).to receive(:new).once.and_return(bot)
      expect(bot).to receive(:authenticated?).and_return false
      expect(bot).to receive(:authenticate).with(ENV['FORUM_BOT_ACCOUNT'], ENV['FORUM_BOT_PASSWORD']).and_return true
      expect(bot).to receive(:get_user_id).with('Salatto').and_return(1234)
      expect(bot).to receive(:send_pm)
        .with(1234, /validation/, %r{/forum-validations/#{@fv.id}/validate\?vid=#{@fv.vid}.*lelelelelelelele.*lalalalalalalala}m)
        .and_return(false)

      expect(@fv.send_pm).to eq false
      expect(@fv.pm_sent?).to eq false
    end

    it 'should not authenticate if its already authenticated' do
      bot = double('ForumBot')
      expect(ForumBot).to receive(:new).once.and_return(bot)
      expect(bot).to receive(:authenticated?).and_return true
      expect(bot).to receive(:get_user_id).with('Salatto').and_return(1234)
      expect(bot).to receive(:send_pm)
        .with(1234, /validation/, %r{/forum-validations/#{@fv.id}/validate\?vid=#{@fv.vid}.*lelelelelelelele.*lalalalalalalala}m)
        .and_return(true)

      expect(@fv.send_pm).to eq true
      expect(@fv.pm_sent?).to eq true
    end

    it 'should return false if authentication fails' do
      bot = double('ForumBot')
      expect(ForumBot).to receive(:new).once.and_return(bot)
      expect(bot).to receive(:authenticated?).and_return false
      expect(bot).to receive(:authenticate).with(ENV['FORUM_BOT_ACCOUNT'], ENV['FORUM_BOT_PASSWORD']).and_return false

      expect(@fv.send_pm).to eq false
      expect(@fv.pm_sent?).to eq false
    end
  end
end
