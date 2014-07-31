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

  describe '#mod' do
    it { expect(version).to respond_to :mod }
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

    context 'validating' do
      it 'should be invalid if both #game_version_start and #game_version_end are null' do
        version = build :mod_version, game_version_start: nil, game_version_end_id: 12389732894213
        expect(version).to be_invalid
      end
    end

    context 'saving' do
      it 'should nullify it if belongs to #game_version_start group' do
        gversion1 = create :game_version, is_group: true
        gversion2 = create :game_version, group: gversion1
        version.game_version_start = gversion1
        version.game_version_end = gversion2
        version.save!
        version.reload
        version.game_version_start.should eq gversion1
        version.game_version_end.should eq nil
      end

      it 'should nullify it if its the same as #game_version_start' do
        gversion1 = create :game_version
        version.game_version_start = gversion1
        version.game_version_end = gversion1
        version.save!
        version.reload
        version.game_version_end.should eq nil
      end

      it 'should switch versions if the end version is older than the start version' do
        gversion1 = create :game_version, sort_order: 1
        gversion2 = create :game_version, sort_order: 2
        version.game_version_start = gversion2
        version.game_version_end = gversion1
        version.save!
        version.reload
        version.game_version_start.should eq gversion1
        version.game_version_end.should eq gversion2
      end

      it 'should allow #game_version_end to be null' do
        version = create :mod_version, game_version_end: nil
      end

      it 'should switch #game_version_end with #game_version_start if #game_version_start is null' do
        gversion = create :game_version
        version = build :mod_version, game_version_start: nil, game_version_end: gversion
        version.save!
        expect(version.game_version_end).to eq nil
        expect(version.game_version_start).to eq gversion
      end
    end
  end

  describe '#sort_order' do
    it { expect(version).to respond_to :sort_order}
    it { expect(version.sort_order).to be_kind_of Integer }
  end

  describe 'scopes' do
    describe '.sort_by_game_version_start' do
      it 'should return th mods versions by the #sort_order of the respective #game_version_start' do
        gv1 = create :game_version, sort_order: 1
        gv2 = create :game_version, sort_order: 2
        mod1 = create :mod_version, game_version_start: gv2
        mod2 = create :mod_version, game_version_start: gv1

        expect(ModVersion.get_by_game_version_start).to eq [mod2, mod1]
      end
    end

    describe '.sort_by_game_version_end' do
      it 'should return th mods versions by the #sort_order of the respective #game_version_end' do
        gv1 = create :game_version, sort_order: 1
        gv2 = create :game_version, sort_order: 2
        gv_1 = create :game_version, sort_order: 0
        gv_2 = create :game_version, sort_order: 0
        mod1 = create :mod_version, game_version_end: gv2, game_version_start: gv_2
        mod2 = create :mod_version, game_version_end: gv1, game_version_start: gv_1

        puts ModVersion.get_by_game_version_end.to_sql

        expect(ModVersion.get_by_game_version_end).to eq [mod2, mod1]
      end
    end
  end

end
