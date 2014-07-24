require 'rails_helper'

module VersionRangeCalculator
  describe VersionsRange do
    before :each do
      @range = VersionsRange.new ['0.1', '0.2', '0.2.1', '0.2.2',
                                 '0.2.3', '0.3.0', '0.3.1', '1.0.0',
                                 '1.0.1', '1.1.0', '1.2.0', '1.2.1',
                                 '1.2.1.1a', '1.2.1.1b', '1.2.1.1c', '1.2.1.1d',
                                 '1.2.2', '1.3.9', '1.3.10a', '1.3.10b',
                                 '2.0.0', '2.0.1', '2.1.0', '2.1.0b',
                                 '2.1.1', '2.1.2', '2.2.0', '2.2.0.1',
                                 '2.3.0', '3.0.0']
    end

    describe '#is_first_in_level?' do
      it { expect(@range.is_first_in_level?('0.1', 0)).to   eq true }
      it { expect(@range.is_first_in_level?('0.1', 1)).to   eq true }
      it { expect(@range.is_first_in_level?('0.2', 1)).to   eq false }
      it { expect(@range.is_first_in_level?('0.2', 2)).to   eq true }
      it { expect(@range.is_first_in_level?('0.2.1', 1)).to eq false }
      it { expect(@range.is_first_in_level?('0.2.1', 2)).to eq false }
      it { expect(@range.is_first_in_level?('0.3.0', 2)).to eq true }
      it { expect(@range.is_first_in_level?('0.3.1', 2)).to eq false }
      it { expect(@range.is_first_in_level?('1.0.0', 0)).to eq false }
      it { expect(@range.is_first_in_level?('1.0.0', 1)).to eq true }
      it { expect(@range.is_first_in_level?('1.1.0', 1)).to eq false }
      it { expect(@range.is_first_in_level?('1.1.0', 2)).to eq true }
      it { expect(@range.is_first_in_level?('1.2.0', 2)).to eq true }
      it { expect(@range.is_first_in_level?('1.2.1', 2)).to eq false }
      it { expect(@range.is_first_in_level?('3.0.0', 1)).to eq true }
      it { expect(@range.is_first_in_level?('3.0.0', 2)).to eq true }
      it { expect(@range.is_first_in_level?('1.2.1', 3)).to eq true }
      it { expect(@range.is_first_in_level?('1.2.1.1a', 3)).to eq false }
    end

    describe '#is_last_in_level?' do
      it { expect(@range.is_last_in_level?('3.0.0', 2)).to eq true }
      it { expect(@range.is_last_in_level?('3.0.0', 1)).to eq true }
      it { expect(@range.is_last_in_level?('3.0.0', 0)).to eq true }
      it { expect(@range.is_last_in_level?('2.3.0', 2)).to eq true }
      it { expect(@range.is_last_in_level?('2.3.0', 1)).to eq true }
      it { expect(@range.is_last_in_level?('2.3.0', 0)).to eq false }
      it { expect(@range.is_last_in_level?('2.2.0.1', 2)).to eq true }
      it { expect(@range.is_last_in_level?('2.2.0', 2)).to eq false }
      it { expect(@range.is_last_in_level?('1.2.2', 2)).to eq true }
      it { expect(@range.is_last_in_level?('1.2.1', 2)).to eq false }
      it { expect(@range.is_last_in_level?('1.2.0', 2)).to eq false }
      it { expect(@range.is_last_in_level?('1.1.0', 2)).to eq true }
      it { expect(@range.is_last_in_level?('1.0.1', 2)).to eq true }
      it { expect(@range.is_last_in_level?('1.0.0', 2)).to eq false }
      it { expect(@range.is_last_in_level?('1.2.1.1d', 3)).to eq true }
    end

    describe '#range_string' do
      it { expect(@range.range_string('0.1', '0.2')).to eq '0.1-0.2' }
      it { expect(@range.range_string('0.1', '1.2.0')).to eq '0.1-1.2.0' }
      it { expect(@range.range_string('0.1', '0.3.1')).to eq '0.x' }
      it { expect(@range.range_string('0.1', '0.3.0')).to eq '0.1-0.3.0' }
      it { expect(@range.range_string('1.2.0', '1.2.2')).to eq '1.2.x' }
      it { expect(@range.range_string('1.0.0', '1.3.10b')).to eq '1.x' }
      it { expect(@range.range_string('1.2.1', '1.2.1.1d')).to eq '1.2.1.x' }
    end
  end
end