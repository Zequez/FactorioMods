require 'rails_helper'

RSpec.describe GameVersion, :type => :model do
  subject(:version) { build :game_version }

  describe '#game' do
    it { expect(version).to respond_to :game }
    it { expect(version.build_game).to be_kind_of Game }
  end

  describe '#sort_order' do
    it { expect(version).to respond_to :sort_order}
    it { expect(version.sort_order).to be_kind_of Integer }
    # it { expect(version).to respond_to :is_group? }
    # it { expect(version.is_group?).to be_kind_of FalseClass }
  end

  # describe '#group' do
  #     it { expect(version).to respond_to :group_id }
  #     it { expect(version).to respond_to :group }

  #     it 'should be of type GameVersionGroup' do
  #       expect(version.build_group).to be_kind_of GameVersionGroup
  #     end
  # end

  #   describe '#group' do
  #     it { expect(version).to respond_to :group_id }
  #     it { expect(version).to respond_to :group }

  #     it 'should be of type GameVersion' do
  #       expect(version.build_group).to be_kind_of GameVersion
  #     end

  #     it 'should save the group' do
  #       group = build :game_version, is_group: true
  #       version = build :game_version, group: group
  #       version.save!
  #       version.reload
  #       version.group.should eq group
  #     end
  #   end

  #   describe '#sub_versions' do
  #     context 'subject is a group an have #sub_versions' do
  #       it 'should return the list of associated versions' do
  #         version_group = create :game_version, is_group: true
  #         versions = []
  #         versions << create(:game_version, group: version_group)
  #         versions << create(:game_version, group: version_group)
  #         versions << create(:game_version, group: version_group)

  #         expect(version_group.sub_versions).to eq versions
  #       end
  #     end
  #   end

  #   describe 'validations' do
  #     context "trying to save a GameVersion with a #group, when it's itself a group" do
  #       it 'should add an error to #group' do
  #         group = create :game_version, is_group: true
  #         version = build :game_version, is_group: true, group: group
  #         expect(version).to be_invalid
  #         expect(version.errors).to have_key :group
  #       end
  #     end

  #     context 'trying to save a GameVersion to a non-group' do
  #       it 'should add an error to #group' do
  #         non_group = create :game_version
  #         version = build :game_version, group: non_group
  #         expect(version).to be_invalid
  #         expect(version.errors).to have_key :group
  #       end
  #     end

  #     context 'trying to save a GameVersion with a sort_order higher than its group' do
  #       it 'should be invalid with an error on #group' do
  #         group = create :game_version, sort_order: 1, is_group: true
  #         version = build :game_version, group: group, sort_order: 2
  #         expect(version).to be_invalid
  #         expect(version.errors).to have_key :group
  #       end
  #     end
  #   end

  #   describe 'callbacks' do
  #     context 'when saving with empty #sort_order' do
  #       context 'with a previous GameVersion with a #sort_order' do
  #         it 'should assign #sort_order to the previous GameVersion sort order plus 1 number' do
  #           create :game_version, sort_order: 123
  #           version = create :game_version, sort_order: nil
  #           expect(version.sort_order).to eq 124
  #         end
  #       end

  #       context 'no other GameVersion' do
  #         it 'should assign #sort_order to 0' do
  #           version = create :game_version, sort_order: nil
  #           expect(version.sort_order).to eq 0
  #         end
  #       end
  #     end
  #   end
  # end

  # describe 'selectors and sorters' do
  #   before :each do
  #     @versions = []
  #     @versions << create(:game_version, number: '0.1', sort_order: 0)
  #     @versions << create(:game_version, number: '0.2', sort_order: 2)
  #     @versions << create(:game_version, number: '0.3', sort_order: 4)
  #     @versions << create(:game_version, number: '0.3.1', sort_order: 6)
  #     @versions << create(:game_version, number: '0.3.2a', sort_order: 8)
  #     @versions << create(:game_version, number: '0.3.2b', sort_order: 10)
  #     @versions << create(:game_version, number: '0.4', sort_order: 12)
  #     @versions << create(:game_version, number: '0.5', sort_order: 14)
  #   end

  #   describe '.sort_by_older_to_newer' do
  #     it 'should return ordered game versions' do
  #       @versions.insert(4, create(:game_version, number: '0.3.1.1', sort_order: 7))

  #       GameVersion.sort_by_older_to_newer.all.should eq @versions
  #     end
  #   end

  #   describe '.sort_by_newer_to_older' do
  #     it 'should return ordered game versions' do
  #       @versions.insert(4, create(:game_version, number: '0.3.1.1', sort_order: 7))

  #       GameVersion.sort_by_newer_to_older.all.should eq @versions.reverse
  #     end
  #   end

  #   describe '.select_older_versions' do
  #     it 'should return a empty array' do
  #       expect(GameVersion.select_older_versions(@versions.first)).to match @versions[0, 0]
  #     end

  #     it 'should return the version 0.1' do
  #       expect(GameVersion.select_older_versions(@versions[1])).to match @versions[0, 1]
  #     end

  #     it 'should return the versions 0.1, 0.2' do
  #       expect(GameVersion.select_older_versions(@versions[2])).to match @versions[0, 2]
  #     end

  #     it 'should return the versions 0.1, 0.2, 0.3' do
  #       expect(GameVersion.select_older_versions(@versions[3])).to match @versions[0, 3]
  #     end

  #     it 'should return the versions 0.1, 0.2, 0.3, 0.3.1' do
  #       expect(GameVersion.select_older_versions(@versions[4])).to match @versions[0, 4]
  #     end

  #     it 'should return the versions 0.1, 0.2, 0.3, 0.3.1, 0.3.2a' do
  #       expect(GameVersion.select_older_versions(@versions[5])).to match @versions[0, 5]
  #     end
  #   end

  #   describe '.select_newer_versions' do
  #     it 'should return 0.2, 0.3, 0.3.0, 0.3.2a, 0.3.2b, 0.4, 0.5' do
  #       expect(GameVersion.select_newer_versions(@versions[0])).to match @versions[1..-1]
  #     end

  #     it 'should return the version 0.3, 0.3.0, 0.3.2a, 0.3.2b, 0.4, 0.5' do
  #       expect(GameVersion.select_newer_versions(@versions[1])).to match @versions[2..-1]
  #     end

  #     it 'should return the versions 0.3.1, 0.3.2a, 0.3.2b, 0.4, 0.5' do
  #       expect(GameVersion.select_newer_versions(@versions[2])).to match @versions[3..-1]
  #     end

  #     it 'should return the versions 0.3.2a, 0.3.2b, 0.4, 0.5' do
  #       expect(GameVersion.select_newer_versions(@versions[3])).to match @versions[4..-1]
  #     end

  #     it 'should return the versions 0.3.2b, 0.4, 0.5' do
  #       expect(GameVersion.select_newer_versions(@versions[4])).to match @versions[5..-1]
  #     end

  #     it 'should return the versions 0.4, 0.5' do
  #       expect(GameVersion.select_newer_versions(@versions[5])).to match @versions[6..-1]
  #     end

  #     it 'should return the versions 0.5' do
  #       expect(GameVersion.select_newer_versions(@versions[6])).to match @versions[7..-1]
  #     end

  #     it 'should return an empty array' do
  #       expect(GameVersion.select_newer_versions(@versions[7])).to match []
  #     end
  #   end
  # end
end
