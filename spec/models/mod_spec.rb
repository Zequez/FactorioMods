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

    describe '#game_version_string' do

    end

    describe '#game_version_start' do
      it { should respond_to :game_version_start }
      it 'should be kind of GameVersion' do
        mod.build_game_version_start
        expect(mod.build_game_version_start).to be_kind_of GameVersion
      end

      it 'should read it from the lowest mod version before saving' do
        mv1 = build :mod_version, sort_order: 1
        mv2 = build :mod_version, sort_order: 2
        mv3 = build :mod_version, sort_order: 3
        mv4 = build :mod_version, sort_order: 4

        mod.versions = [mv1, mv2, mv3, mv4]
        mod.save!

        mod.game_version_start.should eq mv1.game_version_start
        mod.game_version_end.should eq mv4.game_version_end
      end
    end

    describe '#game_version_end' do
      it { should respond_to :game_version_end }
      it 'should be kind of GameVersion' do
        mod.build_game_version_end
        expect(mod.build_game_version_end).to be_kind_of GameVersion
      end
    end
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
        game_version1 = create(:game_version)
        game_version2 = create(:game_version)
        game_version3 = create(:game_version)

        mod_version1 = build(:mod_version, game_version_start: game_version1, game_version_end: game_version2)
        mod_version2 = build(:mod_version, game_version_start: game_version3, game_version_end: nil)
        mod_version3 = build(:mod_version, game_version_start: game_version1, game_version_end: game_version3)
        mod_version4 = build(:mod_version, game_version_start: game_version2, game_version_end: game_version3)

        mod1 = build(:mod, versions: [mod_version1])
        mod2 = build(:mod, versions: [mod_version2])
        mod3 = build(:mod, versions: [mod_version3])
        mod4 = build(:mod, versions: [mod_version4])

        mod1.save!
        mod2.save!
        mod3.save!
        mod4.save!

        puts 'GVS#sort_order = ' + mod1.game_version_start.sort_order.to_s
        puts 'GVE#sort_order = ' + mod1.game_version_end.sort_order.to_s
        puts '#versions = ' + mod1.versions.inspect
        puts 'game_version1 = ' + game_version1.inspect
        puts 'game_version2 = ' + game_version2.inspect
        puts 'game_version3 = ' + game_version3.inspect

        expect(Mod.for_game_version(game_version1)).to eq [mod1, mod3]
        expect(Mod.for_game_version(game_version2)).to eq [mod1, mod3, mod4]
        expect(Mod.for_game_version(game_version3)).to eq [mod2, mod3, mod4]
        # expect(Mod.for_game_version(game_version2)).to eq [mod2, mod3]
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
