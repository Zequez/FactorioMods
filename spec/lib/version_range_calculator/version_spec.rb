require 'rails_helper'

module VersionRangeCalculator
  describe Version do
    describe '#level' do
      context '4 parts version' do
        it 'should return level 4' do
          version = Version.new '1.2.3.4'
          expect(version.level).to eq 4
        end
      end

      context '3 parts version' do
        it 'should return level 3' do
          version = Version.new '1.2.3'
          expect(version.level).to eq 3
        end
      end

      context '2 parts version' do
        it 'should return level 2' do
          version = Version.new '1.2'
          expect(version.level).to eq 2
        end
      end

      context '1 parts version' do
        it 'should return level 1' do
          version = Version.new '1'
          expect(version.level).to eq 1
        end
      end

      context '0 parts version' do
        it 'should return level 0' do
          version = Version.new ''
          expect(version.level).to eq 0
        end
      end

      context 'nil parts version' do
        it 'should return level 0' do
          version = Version.new nil
          expect(version.level).to eq 0
        end
      end
    end

    describe '#sections' do
      context '3 parts version' do
        it 'should an array with 3 elements' do
          version = Version.new '1.2.3'
          version.sections.should eq %w(1 2 3)
        end
      end

      context '2 parts version' do
        it 'should an array with 2 elements' do
          version = Version.new '1.2'
          version.sections.should eq %w(1 2)
        end
      end

      context '1 parts version' do
        it 'should an array with 1 elements' do
          version = Version.new '1'
          version.sections.should eq %w(1)
        end
      end

      context '0 parts version' do
        it 'should an empty array' do
          version = Version.new ''
          version.sections.should eq []
        end
      end

      context 'nil parts version' do
        it 'should an empty array' do
          version = Version.new nil
          version.sections.should eq []
        end
      end
    end
  end
end