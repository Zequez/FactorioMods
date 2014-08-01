require 'rails_helper'

RSpec.describe Mod, :type => :model do
  describe 'attributes' do
    subject(:mod) { build :mod }

    it { should respond_to :name }
    it { should respond_to :author_name }
    it { should respond_to :description }
    it { should respond_to :summary }

    it { should respond_to :github }
    it { should respond_to :github_url } # Alias of #github
    it { should respond_to :license }

    it { should respond_to :first_version_date }
    it { should respond_to :last_version_date }

    # URLs
    it { should respond_to :license_url }
    it { should respond_to :official_url }
    it { should respond_to :forum_post_url }

    # External counters
    it { should respond_to :forum_comments_count }
    it { should respond_to :comments_count }

    # Tracking data
    it { should respond_to :downloads }
    it { should respond_to :downloads_count }
    it { should respond_to :visits }
    it { should respond_to :visits_count }

    # belongs_to
    it { should respond_to :author }
    it { should respond_to :category }

    # has_many
    it { should respond_to :files }
    it { should respond_to :versions }
    it { should respond_to :assets }
    it { should respond_to :tags }
    it { should respond_to :favorites }
    it { should respond_to :favorites_count }

    describe '#author_name' do
      subject { mod.author_name }
      it { should be_kind_of String }

      context 'there is an #author' do
        it 'should be delegated to #author.name' do
          mod.author_name = 'Hello There'
          mod.author_name.should eq 'Hello There'
          mod.author = build :developer, name: 'Bye Macumbo'
          mod.author_name.should eq 'Bye Macumbo'
        end
      end
    end

    describe '#slug' do
      subject { create :mod, name: 'Banana split canaleta cósmica "123" pepep' }
      it { expect(subject.slug).to eq 'banana-split-canaleta-cosmica-123-pepep' }
    end

    describe '#github_path' do
      it 'should return the last part of the #github URL' do
        mod.github = 'http://github.com/zequez/something'
        expect(mod.github_path).to eq 'zequez/something'
      end
    end


    describe '#versions' do
      it 'should be ModVersion type' do
        mod.versions.build
        expect(mod.versions.first).to be_kind_of ModVersion
      end
    end

    describe '#files' do
      it 'should be ModFile type' do
        mod.files.build
        expect(mod.files.first).to be_kind_of ModFile
      end
    end

    describe '#game_versions' do
      it { expect(mod).to respond_to :game_versions }

      it 'should be able to access it through the #versions' do
        mv1 = create :mod_version, mod: mod
        mv2 = create :mod_version, mod: mod
        gv1 = create :game_version
        gv2 = create :game_version
        gv3 = create :game_version
        gv4 = create :game_version
        mv1.game_versions = [gv1, gv2, gv3]
        mv2.game_versions = [gv2, gv3, gv4]

        mod = Mod.first

        mod.game_versions.should match [gv1, gv2, gv3, gv4]
      end
    end

    describe '#game_versions_string' do
      context 'just one game version' do
        it 'returns the lonely game_version#number' do
          mv1 = create :mod_version, mod: mod
          gv1 = create :game_version
          mv1.game_versions = [gv1]
          mod = Mod.first

          expect(mod.game_versions_string).to eq gv1.number
        end
      end

      context 'multiple game versions' do
        it 'returns the game versions numbers separated by a dash' do
          mv1 = create :mod_version, mod: mod
          gv1 = create :game_version
          gv2 = create :game_version
          gv3 = create :game_version
          mv1.game_versions = [gv1, gv2, gv3]
          mod = Mod.first

          expect(mod.game_versions_string).to eq "#{gv1.number}-#{gv3.number}"
        end
      end
    end

    # describe '#game_versions_string' do
    #    it { expect(mod).to respond_to :game_versions_string }

    #   context 'on saving' do
    #     it 'should associate the correct GameVersion based on the string' do
    #       g1 = create :game_version, number: '1.2.3'
    #       g2 = create :game_version, number: '1.2.4'
    #       g3 = create :game_version, number: '1.2.5'
    #       g4 = create :game_version, number: '1.1.1'
    #       g5 = create :game_version, number: '1.4.3'

    #       mod.game_versions_string = '1.2.3, 1.2.4, 1.1.1'
    #       mod.save!
    #       expect(mod.game_versions).to eq [g1, g2, g4]
    #     end

    #     it 'should work with whitespace too' do
    #       g1 = create :game_version, number: '1.2.3'
    #       g2 = create :game_version, number: '1.2.4'
    #       g3 = create :game_version, number: '1.2.5'
    #       g4 = create :game_version, number: '1.1.1'
    #       g5 = create :game_version, number: '1.4.3'

    #       mod.game_versions_string = '1.2.3 1.2.4 1.1.1'
    #       mod.save!
    #       expect(mod.game_versions).to eq [g1, g2, g4]
    #     end

    #     it 'should associate the game versions that belong to a group' do
    #       group = create :game_version_group, number: '1.2.x'
    #       create :game_version, number: '1.1.1'
    #       g1 = create :game_version, number: '1.2.0', group: group
    #       g2 = create :game_version, number: '1.2.1', group: group
    #       g3 = create :game_version, number: '1.2.3', group: group

    #       mod.game_versions_string = '1.2.x'
    #       mod.save!
    #       expect(mod.game_versions).to eq [g1, g2, g3]
    #     end
    #   end

    #   context 'on loading' do
    #     it 'should return a list of GameVersions as strings' do
    #       create :game_version, number:  '1.2.3', sort_order: 1
    #       create :game_version, number:  '1.2.4', sort_order: 2
    #       create :game_version, number:  '1.2.5', sort_order: 3

    #       mod.game_versions_string = '1.2.5, 1.2.3    1.2.4'
    #       mod.save!
    #       mod = Mod.first
    #       expect(mod.game_versions_string).to eq '1.2.5, 1.2.3, 1.2.4'
    #     end

    #     it 'should return a group if its composed from the whole group' do
    #       group = create :game_version_group, number: '1.2.x'
    #       create :game_version, number: '1.1.1'
    #       g1 = create :game_version, number: '1.2.0', group: group
    #       g2 = create :game_version, number: '1.2.1', group: group
    #       g3 = create :game_version, number: '1.2.3', group: group

    #       mod.game_versions_string = '1.2.x'
    #       mod.save!
    #       expect(mod.game_versions_string).to eq '1.2.x'
    #     end
    #   end

    #   context 'validation' do
    #     it 'should add an error when the game versions cannot be found' do
    #       g1 = create :game_version, number: '1.2.3'
    #       mod.game_versions_string = '1.2.3, 4.3.2'
    #       expect(mod).to be_invalid
    #       expect(mod.errors).to have_key :game_versions_string
    #     end
    #   end
    # end

    # describe '#game_versions' do
    #   it { expect(mod).to respond_to :game_versions }
      # it 'should be of type GameVersion' do
      #   expect(mod.game_versions.build).to be_kind_of GameVersion
      # end
      # it 'should be able to save and load' do
      #   create :game_version
      #   create :game_version
      #   create :game_version
      #   game_versions = GameVersion.all
      #   mod.game_versions = game_versions
      #   mod.save!
      #   mod = Mod.first
      #   expect(mod.game_versions.size).to eq 3
      #   expect(mod.game_versions).to eq game_versions
      # end
    # end

  #   describe '#game_version_start' do
  #     it { should respond_to :game_version_start }
  #     it 'should be kind of GameVersion' do
  #       mod.build_game_version_start
  #       expect(mod.build_game_version_start).to be_kind_of GameVersion
  #     end

  #     it 'should read it from the lowest mod version before saving' do
  #       mv1 = build :mod_version, sort_order: 1
  #       mv2 = build :mod_version, sort_order: 2
  #       mv3 = build :mod_version, sort_order: 3
  #       mv4 = build :mod_version, sort_order: 4

  #       mod.versions = [mv1, mv2, mv3, mv4]
  #       mod.save!

  #       mod.game_version_start.should eq mv1.game_version_start
  #       mod.game_version_end.should eq mv4.game_version_end
  #     end
  #   end

  #   describe '#game_version_end' do
  #     it { should respond_to :game_version_end }
  #     it 'should be kind of GameVersion' do
  #       mod.build_game_version_end
  #       expect(mod.build_game_version_end).to be_kind_of GameVersion
  #     end
  #   end
  end

  describe 'scopes' do
    describe '.in_category' do
      it 'should filter results by category' do
        mod1 = create(:mod)
        mod2 = create(:mod, category: mod1.category)
        mod3 = create(:mod)

        Mod.in_category(mod1.category).all.should eq [mod1, mod2]
      end
    end

    describe '.for_game_version' do
      it 'select mods that have a version for a specific version' do
        gv1 = create(:game_version)
        gv2 = create(:game_version)
        gv3 = create(:game_version)

        mv1 = build(:mod_version, game_versions: [gv1, gv2])
        mv2 = build(:mod_version, game_versions: [gv2, gv3])
        mv3 = build(:mod_version, game_versions: [gv1, gv2, gv3])
        mv4 = build(:mod_version, game_versions: [gv3])

        mod1 = build(:mod, versions: [mv1])
        mod2 = build(:mod, versions: [mv2])
        mod3 = build(:mod, versions: [mv3])
        mod4 = build(:mod, versions: [mv4])

        mod1.save!
        mod2.save!
        mod3.save!
        mod4.save!

        expect(Mod.for_game_version(gv1)).to eq [mod1, mod3]
        expect(Mod.for_game_version(gv2)).to eq [mod1, mod2, mod3]
        expect(Mod.for_game_version(gv3)).to eq [mod2, mod3, mod4]
      end

      it 'works with this configuration too' do
        m1 = create :mod
        m2 = create :mod
        m3 = create :mod
        gv1 = create :game_version, number: '1.1.x'
        gv2 = create :game_version, number: '1.2.x'
        gv3 = create :game_version, number: '1.3.x'
        mv1 = create :mod_version, game_versions: [gv1, gv2], mod: m1
        mv2 = create :mod_version, game_versions: [gv2, gv3], mod: m2
        mv3 = create :mod_version, game_versions: [gv3], mod: m3

        expect(Mod.for_game_version(gv1)).to match [m1]
        expect(Mod.for_game_version(gv2)).to match [m1, m2]
        expect(Mod.for_game_version(gv3)).to match [m2, m3]
      end
    end

    describe '.sort_by_most_recent' do
      context 'there are no mods' do
        it 'should return empty' do
          Mod.sort_by_most_recent.all.should be_empty
        end
      end

      context 'there are some mods' do
        it 'should return them by #updated_at date' do
          mod1 = create(:mod)
          mod2 = create(:mod)
          mod3 = create(:mod)
          mod2.update_attribute :updated_at, Time.now

          Mod.sort_by_most_recent.all.should eq [mod2, mod3, mod1]
        end
      end
    end

    describe '.sort_by_alpha' do
      it 'should sort the results by #name' do
        mods = []
        mods << create(:mod, name: 'Banana')
        mods << create(:mod, name: 'Avocado')
        mods << create(:mod, name: 'Caca')

        expect(Mod.sort_by_alpha).to match [mods[1], mods[0], mods[2]]
      end
    end

    describe '.sort_by_forum_comments' do
      it 'should sort the results by #forum_comments_count' do
        mods = []
        mods << create(:mod, forum_comments_count: 8)
        mods << create(:mod, forum_comments_count: 1)
        mods << create(:mod, forum_comments_count: 3)
        mods << create(:mod, forum_comments_count: 5)
        mods << create(:mod, forum_comments_count: 4)

        expect(Mod.sort_by_forum_comments).to match [mods[0], mods[3], mods[4], mods[2], mods[1]]
      end
    end

    describe '.sort_by_downloads' do
      it 'should sort the results by #forum_comments_count' do
        mods = []
        mods << create(:mod, downloads_count: 2)
        mods << create(:mod, downloads_count: 1)
        mods << create(:mod, downloads_count: 3)
        mods << create(:mod, downloads_count: 5)
        mods << create(:mod, downloads_count: 4)

        expect(Mod.sort_by_downloads).to match [mods[3], mods[4], mods[2], mods[0], mods[1]]
      end
    end
  end
end
