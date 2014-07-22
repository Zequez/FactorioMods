require 'rails_helper'

RSpec.describe ModVersion, :type => :model do
  subject(:version) { build :mod_version }

  describe '#number' do
    it { expect(version).to respond_to :number }
    it { expect(version.number).to be_kind_of String }
  end

  describe '#released_at' do
    it { expect(version).to respond_to :released_at }
    it { expect(version.released_at).to be_kind_of Date }
  end

  describe '#game_version_start' do
    it { expect(version).to respond_to :game_version_start }
    it 'should be a GameVersion' do
      version.build_game_version_start
      expect(version.game_version_start).to be_kind_of GameVersion
    end
  end

  describe '#game_version_end' do
    it { expect(version).to respond_to :game_version_end }
    it 'should be a GameVersion' do
      version.build_game_version_end
      expect(version.game_version_end).to be_kind_of GameVersion
    end
  end

  describe '#sort_order' do
    it { expect(version).to respond_to :sort_order}
    it { expect(version.sort_order).to be_kind_of Integer }
  end

  describe '#game_version' do
    it { expect(version).to respond_to :game_version }
    it { expect(version.game_version).to be_kind_of String }

    context 'on save' do
      it 'should read the #game_version_start.range_string(#game_version_end) and save it as #game_version' do
        expect(version.game_version_start).to receive(:range_string).with(version.game_version_end).and_return('10.x')
        version.save!
        expect(version.game_version).to eq '10.x'
      end
    end
  end
end
