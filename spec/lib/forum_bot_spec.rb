describe ForumBot do
  forum_user = ENV['FORUM_BOT_ACCOUNT']
  forum_password = ENV['FORUM_BOT_PASSWORD']
  subject(:bot) { ForumBot.new }

  def cassette(name)
    VCR.use_cassette("forum_bot/#{name}", record: :new_episodes) do
      yield
    end
  end

  describe '#new' do
    it 'should initialize without params' do
      ForumBot.new
    end
  end

  describe '#authenticate' do
    context 'login failed' do
      it 'should return false' do
        cassette(:auth_invalid) do
          expect(bot.authenticate('invalid user', 'invalid password')).to eq false
        end
        expect(bot.authenticated?).to eq false
      end
    end

    context 'login succeeded' do
      it 'should return true' do
        cassette(:auth_valid) do
          expect(bot.authenticate(forum_user, forum_password)).to eq true
        end
        expect(bot.authenticated?).to eq true
      end
    end
  end

  describe '#get_user_id' do
    it 'should return the user ID from the name' do
      cassette(:get_user_id_real) do
        bot.authenticate(forum_user, forum_password)
        expect(bot.get_user_id('FactorioModsBot')).to eq 8771
      end
    end

    it 'should return nil for a non existant user' do
      cassette(:get_user_id_nonesense) do
        bot.authenticate(forum_user, forum_password)
        expect(bot.get_user_id('hnaersithneirsahtenirsahtsra')).to eq nil
      end
    end

    it "should not return a user that isn't" do
      cassette(:get_user_id_partial) do
        bot.authenticate(forum_user, forum_password)
        expect(bot.get_user_id('a')).to eq nil
      end
    end
  end

  describe '#send_pm' do
    context 'logged in' do
      it 'should send a PM and return true' do
        cassette(:auth_valid) do
          bot.authenticate(forum_user, forum_password)
          expect(bot.send_pm(8771, 'Subject', 'Some text')).to eq true
        end
      end
    end

    context 'not logged in' do
      it 'should send a PM and return true' do
        cassette(:auth_invalid) do
          expect(bot.send_pm(8771, 'Subject', 'Some text')).to eq false
        end
      end
    end
  end
end
