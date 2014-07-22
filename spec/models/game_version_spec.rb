require 'rails_helper'

RSpec.describe GameVersion, :type => :model do
  describe '#level' do
    context '4 parts version' do
      it 'should return level 4' do
        version = build :game_version, number: '1.2.3.4'
        expect(version.level).to eq 4
      end
    end

    context '3 parts version' do
      it 'should return level 3' do
        version = build :game_version, number: '1.2.3'
        expect(version.level).to eq 3
      end
    end

    context '2 parts version' do
      it 'should return level 2' do
        version = build :game_version, number: '1.2'
        expect(version.level).to eq 2
      end
    end

    context '1 parts version' do
      it 'should return level 1' do
        version = build :game_version, number: '1'
        expect(version.level).to eq 1
      end
    end

    context '0 parts version' do
      it 'should return level 0' do
        version = build :game_version, number: ''
        expect(version.level).to eq 0
      end
    end

    context 'nil parts version' do
      it 'should return level 0' do
        version = build :game_version, number: nil
        expect(version.level).to eq 0
      end
    end
  end

  describe '#sections' do
    context '3 parts version' do
      it 'should an array with 3 elements' do
        version = build :game_version, number: '1.2.3'
        version.sections.should eq %w(1 2 3)
      end
    end

    context '2 parts version' do
      it 'should an array with 2 elements' do
        version = build :game_version, number: '1.2'
        version.sections.should eq %w(1 2)
      end
    end

    context '1 parts version' do
      it 'should an array with 1 elements' do
        version = build :game_version, number: '1'
        version.sections.should eq %w(1)
      end
    end

    context '0 parts version' do
      it 'should an empty array' do
        version = build :game_version, number: ''
        version.sections.should eq []
      end
    end

    context 'nil parts version' do
      it 'should an empty array' do
        version = build :game_version, number: nil
        version.sections.should eq []
      end
    end
  end

  describe '#is_first_in_level' do
    # context 'only one version' do
    #   subject(:version) { create :game_version, number: '1.2.3' }

    #   it 'should return true for level 3' do
    #     version.is_first_in_level(3).should eq true
    #   end

    #   it 'should return true for level 2' do
    #     version.is_first_in_level(2).should eq true
    #   end

    #   it 'should return true for level 1' do
    #     version.is_first_in_level(1).should eq true
    #   end
    # end

    # context '2 versions, different level 1' do
    #   subject(:version) { create :game_version, number: '1.2.3' }
    #   before(:each) { create :game_version, number: '2.3.5' }

    #   it 'should return true for level 3' do
    #     version.is_first_in_level(3).should eq true
    #   end

    #   it 'should return true for level 2' do
    #     version.is_first_in_level(2).should eq true
    #   end

    #   it 'should return true for level 1' do
    #     version.is_first_in_level(1).should eq true
    #   end
    # end

    # context '2 versions, different level 2' do
    #   subject(:version) { create :game_version, number: '1.2.3' }
    #   before(:each) { create :game_version, number: '1.3.5' }

    #   it 'should return true for level 3' do
    #     version.is_first_in_level(3).should eq true
    #   end

    #   it 'should return true for level 2' do
    #     version.is_first_in_level(2).should eq true
    #   end

    #   it 'should return true for level 1' do
    #     version.is_first_in_level(1).should eq true
    #   end
    # end

    # context '2 versions, different level 1, subject is second' do
    #   subject(:version) { create :game_version, number: '2.2.3' }
    #   before(:each) { create :game_version, number: '1.3.5' }

    #   it 'should return true for level 3' do
    #     version.is_first_in_level(3).should eq true
    #   end

    #   it 'should return true for level 2' do
    #     version.is_first_in_level(2).should eq true
    #   end

    #   it 'should return false for level 1' do
    #     version.is_first_in_level(1).should eq false
    #   end
    # end

    # context '2 versions, different level 2, subject is second' do
    #   subject(:version) { create :game_version, number: '1.4.3' }
    #   before(:each) { create :game_version, number: '1.3.5' }

    #   it 'should return true for level 3' do
    #     version.is_first_in_level(3).should eq true
    #   end

    #   it 'should return false for level 2' do
    #     version.is_first_in_level(2).should eq false
    #   end

    #   it 'should return false for level 1' do
    #     version.is_first_in_level(1).should eq false
    #   end
    # end

    # context '2 versions, different level 3, subject is second' do
    #   subject(:version) { create :game_version, number: '1.3.7' }
    #   before(:each) { create :game_version, number: '1.3.5' }

    #   it 'should return false for level 3' do
    #     version.is_first_in_level(3).should eq false
    #   end

    #   it 'should return false for level 2' do
    #     version.is_first_in_level(2).should eq false
    #   end

    #   it 'should return false for level 1' do
    #     version.is_first_in_level(1).should eq false
    #   end
    # end

    context 'multiple versions' do
      before :each do
        create :game_version, number: '0.1'
        create :game_version, number: '0.2'
        create :game_version, number: '0.2.1'
        create :game_version, number: '0.2.2'
        create :game_version, number: '0.2.3'
        create :game_version, number: '0.3.0'
        create :game_version, number: '0.3.1'
        create :game_version, number: '1.0.0'
        create :game_version, number: '1.0.1'
        create :game_version, number: '1.1.0'
        create :game_version, number: '1.2.0'
        create :game_version, number: '1.2.1'
        create :game_version, number: '1.2.1.1a'
        create :game_version, number: '1.2.1.1b'
        create :game_version, number: '1.2.1.1c'
        create :game_version, number: '1.2.1.1d'
        create :game_version, number: '1.2.2'
        create :game_version, number: '1.3.9'
        create :game_version, number: '1.3.10a'
        create :game_version, number: '1.3.10b'
        create :game_version, number: '2.0.0'
        create :game_version, number: '2.0.1'
        create :game_version, number: '2.1.0'
        create :game_version, number: '2.1.0b'
        create :game_version, number: '2.1.1'
        create :game_version, number: '2.1.2'
        create :game_version, number: '2.2.0'
        create :game_version, number: '2.2.0.1'
        create :game_version, number: '2.3.0'
        create :game_version, number: '3.0.0'
      end

      describe '#range_string' do
        def range_string(number1, number2)
          version1 = GameVersion.find_by_number(number1)
          version2 = GameVersion.find_by_number(number2)
          version1.range_string(version2)
        end

        it { expect(range_string('0.1', '0.2')).to eq '0.1-0.2' }
        it { expect(range_string('0.1', '1.2.0')).to eq '0.1-1.2.0' }
        it { expect(range_string('0.1', '0.3.1')).to eq '0.x' }
        it { expect(range_string('0.1', '0.3.0')).to eq '0.1-0.3.0' }
        it { expect(range_string('1.2.0', '1.2.2')).to eq '1.2.x' }
        it { expect(range_string('1.0.0', '1.3.10b')).to eq '1.x' }
        it { expect(range_string('1.2.1', '1.2.1.1d')).to eq '1.2.1.x' }
      end

      describe '#is_first_in_level?' do
        def is_first_in_level?(number, level)
          GameVersion.find_by_number(number).is_first_in_level?(level)
        end

        it { expect(is_first_in_level?('0.1', 0)).to   eq true }
        it { expect(is_first_in_level?('0.1', 1)).to   eq true }
        it { expect(is_first_in_level?('0.2', 1)).to   eq false }
        it { expect(is_first_in_level?('0.2', 2)).to   eq true }
        it { expect(is_first_in_level?('0.2.1', 1)).to eq false }
        it { expect(is_first_in_level?('0.2.1', 2)).to eq false }
        it { expect(is_first_in_level?('0.3.0', 2)).to eq true }
        it { expect(is_first_in_level?('0.3.1', 2)).to eq false }
        it { expect(is_first_in_level?('1.0.0', 0)).to eq false }
        it { expect(is_first_in_level?('1.0.0', 1)).to eq true }
        it { expect(is_first_in_level?('1.1.0', 1)).to eq false }
        it { expect(is_first_in_level?('1.1.0', 2)).to eq true }
        it { expect(is_first_in_level?('1.2.0', 2)).to eq true }
        it { expect(is_first_in_level?('1.2.1', 2)).to eq false }
        it { expect(is_first_in_level?('3.0.0', 1)).to eq true }
        it { expect(is_first_in_level?('3.0.0', 2)).to eq true }
        it { expect(is_first_in_level?('1.2.1', 3)).to eq true }
        it { expect(is_first_in_level?('1.2.1.1a', 3)).to eq false }
      end

      describe '#is_last_in_level?' do
        def is_last_in_level?(number, level)
          GameVersion.find_by_number(number).is_last_in_level?(level)
        end

        it { expect(is_last_in_level?('3.0.0', 2)).to eq true }
        it { expect(is_last_in_level?('3.0.0', 1)).to eq true }
        it { expect(is_last_in_level?('3.0.0', 0)).to eq true }
        it { expect(is_last_in_level?('2.3.0', 2)).to eq true }
        it { expect(is_last_in_level?('2.3.0', 1)).to eq true }
        it { expect(is_last_in_level?('2.3.0', 0)).to eq false }
        it { expect(is_last_in_level?('2.2.0.1', 2)).to eq true }
        it { expect(is_last_in_level?('2.2.0', 2)).to eq false }
        it { expect(is_last_in_level?('1.2.2', 2)).to eq true }
        it { expect(is_last_in_level?('1.2.1', 2)).to eq false }
        it { expect(is_last_in_level?('1.2.0', 2)).to eq false }
        it { expect(is_last_in_level?('1.1.0', 2)).to eq true }
        it { expect(is_last_in_level?('1.0.1', 2)).to eq true }
        it { expect(is_last_in_level?('1.0.0', 2)).to eq false }
        it { expect(is_last_in_level?('1.2.1.1d', 3)).to eq true }
      end

    end
  end

  describe '#compare_section' do
    subject(:version) { build :game_version }

    it { expect(version.compare_section('1', '2')).to be < 0 }
    it { expect(version.compare_section('2', '1')).to be > 0 }
    it { expect(version.compare_section('1', '1')).to be == 0 }
    it { expect(version.compare_section('10', '2')).to be > 0 }
    it { expect(version.compare_section('10b', '10a')).to be > 0 }
    it { expect(version.compare_section('10b', '10b')).to be == 0 }
    it { expect(version.compare_section('10a', '10b')).to be < 0 }
  end

  describe '#similarity_level' do
    def similarity_level(number1, number2)
      build(:game_version, number: number1).similarity_level(build(:game_version, number: number2))
    end

    it { expect(similarity_level('1.0.0', '1.1.1')).to eq 1 }
    it { expect(similarity_level('1.1.1', '1.1.1')).to eq 3 }
    it { expect(similarity_level('1', '1.1')).to eq 1 }
    it { expect(similarity_level('2.0', '3.1')).to eq 0 }
    it { expect(similarity_level('1.2.3.4.5', '1.2.3.4.5.6')).to eq 5 }
    it { expect(similarity_level('1.2.3.4.5.6', '1.2.3.4.5')).to eq 5 }
    it { expect(similarity_level('1.0.3.4.5.6', '1.1.3.4.5')).to eq 1 }
  end



  describe 'versions selectors and sorters' do
    before :each do
      @versions = []
      @versions << create(:game_version, number: '0.1')
      @versions << create(:game_version, number: '0.2')
      @versions << create(:game_version, number: '0.3')
      @versions << create(:game_version, number: '0.3.1')
      @versions << create(:game_version, number: '0.3.2a')
      @versions << create(:game_version, number: '0.3.2b')
      @versions << create(:game_version, number: '0.4')
      @versions << create(:game_version, number: '0.5')
    end

    describe '.sort_by_older_to_newer' do
      it 'should return ordered game versions' do
        @versions.insert(4, create(:game_version, number: '0.3.1.1'))

        GameVersion.sort_by_older_to_newer.all.should eq @versions
      end
    end

    describe '.sort_by_newer_to_older' do
      it 'should return ordered game versions' do
        @versions.insert(4, create(:game_version, number: '0.3.1.1'))

        GameVersion.sort_by_newer_to_older.all.should eq @versions.reverse
      end
    end

    describe '.select_older_versions' do
      it 'should return a empty array' do
        expect(GameVersion.select_older_versions(@versions.first)).to match @versions[0, 0]
      end

      it 'should return the version 0.1' do
        expect(GameVersion.select_older_versions(@versions[1])).to match @versions[0, 1]
      end

      it 'should return the versions 0.1, 0.2' do
        expect(GameVersion.select_older_versions(@versions[2])).to match @versions[0, 2]
      end

      it 'should return the versions 0.1, 0.2, 0.3' do
        expect(GameVersion.select_older_versions(@versions[3])).to match @versions[0, 3]
      end

      it 'should return the versions 0.1, 0.2, 0.3, 0.3.1' do
        expect(GameVersion.select_older_versions(@versions[4])).to match @versions[0, 4]
      end

      it 'should return the versions 0.1, 0.2, 0.3, 0.3.1, 0.3.2a' do
        expect(GameVersion.select_older_versions(@versions[5])).to match @versions[0, 5]
      end
    end

    describe '.select_newer_versions' do
      it 'should return 0.2, 0.3, 0.3.0, 0.3.2a, 0.3.2b, 0.4, 0.5' do
        expect(GameVersion.select_newer_versions(@versions[0])).to match @versions[1..-1]
      end

      it 'should return the version 0.3, 0.3.0, 0.3.2a, 0.3.2b, 0.4, 0.5' do
        expect(GameVersion.select_newer_versions(@versions[1])).to match @versions[2..-1]
      end

      it 'should return the versions 0.3.1, 0.3.2a, 0.3.2b, 0.4, 0.5' do
        expect(GameVersion.select_newer_versions(@versions[2])).to match @versions[3..-1]
      end

      it 'should return the versions 0.3.2a, 0.3.2b, 0.4, 0.5' do
        expect(GameVersion.select_newer_versions(@versions[3])).to match @versions[4..-1]
      end

      it 'should return the versions 0.3.2b, 0.4, 0.5' do
        expect(GameVersion.select_newer_versions(@versions[4])).to match @versions[5..-1]
      end

      it 'should return the versions 0.4, 0.5' do
        expect(GameVersion.select_newer_versions(@versions[5])).to match @versions[6..-1]
      end

      it 'should return the versions 0.5' do
        expect(GameVersion.select_newer_versions(@versions[6])).to match @versions[7..-1]
      end

      it 'should return an empty array' do
        expect(GameVersion.select_newer_versions(@versions[7])).to match []
      end
    end
  end
end
