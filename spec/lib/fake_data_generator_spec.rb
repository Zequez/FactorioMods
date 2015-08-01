describe FakeDataGenerator, vcr: { cassette_name: 'fake_data_generator', record: :new_episodes } do
  describe '#generate' do
    it 'should generate data on each table for testing purposes without failing' do
      generator = FakeDataGenerator.new
      generator.generate
      
      expect(Game.all.count).to be 1
      expect(GameVersion.all.count).to be >= 5
      expect(User.all.count).to be >= 5
      expect(Subforum.all.count).to be >= 1
      expect(ForumPost.all.count).to be >= 10
      expect(Mod.all.count).to be >= 10
      expect(ModVersion.all.count).to be >= 10
      expect(ModFile.all.count).to be >= 10
    end
  end
end