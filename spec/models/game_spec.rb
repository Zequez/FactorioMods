require 'rails_helper'

RSpec.describe Game, :type => :model do
  subject(:game) { build :game }
  it { expect(game).to respond_to :versions }
  it { expect(game.versions.build).to be_kind_of GameVersion }

  describe '#versions' do
    it 'should be able to create a game with versions' do
      versions = []
      versions.push build :game_version
      versions.push build :game_version
      versions.push build :game_version

      game.versions = versions
      expect { game.save! }.to_not raise_error
    end
  end

  it 'should not allow to create more than one game' do
    create :game
    game = build :game
    expect{game.save}.to raise_error
  end
end
