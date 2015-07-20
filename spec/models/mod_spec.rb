require 'rails_helper'

RSpec.describe Mod, :type => :model do
  describe 'attributes' do
    subject(:mod) { build :mod }

    it { should respond_to :name }
    it { should respond_to :author_name }
    it { should respond_to :description }
    it { should respond_to :summary }

    it { should respond_to :github }
    it { should respond_to :github_url }
    it { should respond_to :license }

    it { should respond_to :first_version_date }
    it { should respond_to :last_version_date }

    it { should respond_to :media_links }
    it { should respond_to :imgur }
    it { should respond_to :imgur_url }
    it { should respond_to :imgur_thumbnail }
    it { should respond_to :imgur_normal }

    it { should respond_to :last_release_date }

    # URLs
    it { should respond_to :license_url }
    it { should respond_to :official_url }
    it { should respond_to :forum_url }

    # External counters
    it { should respond_to :forum_comments_count }
    it { should respond_to :comments_count }

    # Tracking data
    # it { should respond_to :downloads }
    # it { should respond_to :downloads_count }
    # it { should respond_to :visits }
    # it { should respond_to :visits_count }

    # belongs_to
    it { should respond_to :author }
    it { should respond_to :categories }
    it { should respond_to :last_version }
    # has_many
    it { should respond_to :files }
    it { should respond_to :versions }
    # it { should respond_to :tags }
    it { should respond_to :favorites }
    it { should respond_to :favorites_count }

    describe 'validation' do
      it 'should be valid by default from the factory' do
        mod = build :mod
        expect(mod).to be_valid
      end

      it 'should be invalid with an invalid #official_url' do
        mod = build :mod, official_url: 'javascript:alert("Potato")'
        expect(mod).to be_invalid
      end

      it 'should be invalid with an invalid #license_url' do
        mod = build :mod, license_url: 'javascript:alert("Potato")'
        expect(mod).to be_invalid
      end

      it 'should be invalid with an invalid #forum_url' do
        mod = build :mod, forum_url: 'javascript:alert("Potato")'
        expect(mod).to be_invalid
      end

      it 'should be invalid without name' do
        mod = build :mod, name: ''
        expect(mod).to be_invalid
      end

      it 'should be valid with a name with 50 characters or less' do
        mod = build :mod, name: 'a'*50
        expect(mod).to be_valid
      end

      it 'should be invalid with a name with more than 50 characters' do
        mod = build :mod, name: 'a'*51
        expect(mod).to be_invalid
      end

      it 'should be valid with the same name as an existing mod' do
        mod1 = create :mod, name: 'PotatoMod'
        mod2 = build :mod, name: 'PotatoMod'
        expect(mod2).to be_valid
      end

      it 'should be invalid without category' do
        mod = build :mod
        mod.categories = []
        expect(mod).to be_invalid
      end

      it 'should be valid with 8 categories or less' do
        categories = 8.times.map{ create :category }
        mod.categories = categories
        expect(mod).to be_valid
      end

      it 'should be invalid with more than 8 categories' do
        categories = 9.times.map{ create :category }
        mod.categories = categories
        expect(mod).to be_invalid
      end

      it 'should be valid with a 1000 letters or shorter summary' do
        mod.summary = 'a'*1000
        expect(mod).to be_valid
      end

      it 'should be invalid with a summary longer than 1000 letters' do
        mod.summary = 'a'*1001
        expect(mod).to be_invalid
      end

      it 'should be invalid with the same slug as another mod' do
        mod1 = create :mod, slug: 'potato'
        mod2 = build :mod, slug: 'potato', name: 'apple' # We are forcing this slug
        expect(mod2).to be_invalid
        expect(mod2.errors[:slug].size).to eq 1
      end
    end

    describe '#author_name' do
      context 'there is an #author' do
        it 'should be delegated to #author.name' do
          mod.author = build :user, name: 'ByeMacumbo'
          mod.author_name.should eq 'ByeMacumbo'
        end
      end
    end

    describe '#author' do
      it 'should be set #author_name to #author.name when #author is assigned and saved' do
        mod = create :mod, author_name: 'HeyDonalds', author: nil
        user = create :user, name: 'Yeah'
        mod.author = user
        mod.save!
        expect(mod.author_name).to eq 'Yeah'
        mod.author = nil
        mod.save!
        expect(mod.author_name).to eq 'Yeah'
      end

      it 'should set author#is_dev to true after saving' do
        mod = create :mod, author: nil
        user = create :user, name: 'YeahYeah'
        expect(user.is_dev?).to eq false
        mod.author = user
        expect(user.is_dev?).to eq false
        mod.save!
        expect(user.is_dev?).to eq true
      end
    end

    describe '#slug' do
      it 'should slug all characters from the name' do
        mod = create :mod, name: 'Banana split canaleta cósmica "123" pepep'
        expect(mod.slug).to eq 'banana-split-canaleta-cosmica-123-pepep'
      end

      it 'should use the author name as the second part of the slug when clashing' do
        mod1 = create :mod, name: 'Potato!'
        mod2 = create :mod, name: 'Potato?', author_name: 'Salad'
        expect(mod1.slug).to eq 'potato'
        expect(mod2.slug).to eq 'potato-by-salad'
      end

      it 'should not allow the "new" slug as it clashes with the controller action' do
        mod = create :mod, name: 'New!', author_name: 'Potato'
        expect(mod.slug).to eq 'new-by-potato'
      end
    end

    describe '#github' do
      it 'should read it from a Github URL and save it as a path' do
        mod.github = 'http://github.com/zequez/something'
        expect(mod.github).to eq 'zequez/something'
      end

      it 'should read it as a path and save it cleaned up' do
        mod.github = '/zequez/something/'
        expect(mod.github).to eq 'zequez/something'
      end

      describe 'validation' do
        it 'should be valid with a valid path' do
          mod.github = 'zequez/something'
          expect(mod).to be_valid
        end

        it 'should not be valid with a different domain' do
          mod.github = 'http://potato.com/zequez/something'
          expect(mod).to be_invalid
        end

        it 'should not be valid with multiple bars' do
          mod.github = 'zequez/something/else'
          expect(mod).to be_invalid
        end
      end

      describe '#github_path' do
        it 'should return the github path, same as #github' do
          mod.github = 'http://github.com/zequez/something'
          expect(mod.github_path).to eq 'zequez/something'
        end
      end

      describe '#github_url' do
        it 'should use the path to generate a URL' do
          mod.github = 'zequez/something'
          expect(mod.github_url).to eq 'http://github.com/zequez/something'
        end
      end
    end

    describe '#versions' do
      it 'should be ModVersion type' do
        mod.versions.build
        expect(mod.versions.first).to be_kind_of ModVersion
      end
    end

    describe '#last_version' do
      it 'should get it from the #versions lists before saving' do
        mv1 = build(:mod_version, sort_order: 3, released_at: 5.days.ago)
        mv2 = build(:mod_version, sort_order: 1, released_at: 10.days.ago)
        mv3 = build(:mod_version, sort_order: 2, released_at: 1.month.ago)
        mod.versions = [mv2, mv1, mv3]
        mod.save!
        expect(mod.last_version).to eq mv1
      end
    end

    describe '#last_release_date' do
      it 'should get it from the #last_version before saving' do
        date = 5.days.ago
        mv1 = build(:mod_version, sort_order: 1, released_at: date)
        mv2 = build(:mod_version, sort_order: 2, released_at: 10.days.ago)
        mv3 = build(:mod_version, sort_order: 3, released_at: 1.month.ago)
        mod.versions = [mv2, mv1, mv3]
        mod.save!
        expect(mod.last_release_date).to eq date
      end
    end

    describe '#has_versions?' do
      it 'should return false if the mod has no versions' do
        mod = create :mod, versions: []
        expect(mod.has_versions?).to eq false
      end

      it 'should return true if the mod has a version' do
        mod = create :mod, versions: []
        create :mod_version, mod: mod
        mod = Mod.first
        expect(mod.has_versions?).to eq true
      end
    end

    describe '#has_files?' do
      it 'should return false if the mod has no files' do
        mod = create :mod, versions: []
        expect(mod.has_files?).to eq false
      end

      it 'should return true if the mod has at least a file' do
        mod = build :mod, versions: []
        mod.save!
        mod_version = create :mod_version, mod: mod
        mod_file = create :mod_file, mod_version: mod_version
        mod = Mod.first
        expect(mod.has_files?).to eq true
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

      context 'it should update after I change the game versions of the mod versions to a single version' do
        it 'returns the game version number' do
          mv1 = create :mod_version, mod: mod
          gv1 = create :game_version
          gv2 = create :game_version
          gv3 = create :game_version
          mv1.game_versions = [gv1, gv2, gv3]
          mv1.game_versions = [gv1]
          mod = Mod.first

          expect(mod.game_versions_string).to eq "#{gv1.number}"
        end
      end
    end

    describe '#latest_version' do
      it 'returns latest mod version' do
        mv1 = create :mod_version, mod: mod, released_at: 3.years.ago
        mv2 = create :mod_version, mod: mod, released_at: 2.months.ago
        mv3 = create :mod_version, mod: mod, released_at: 1.day.ago
        mod.reload
        expect(mod.latest_version).to eq mv3
      end

      context 'no mod versions' do
        it 'returns nil' do
          expect(mod.latest_version).to eq nil
        end
      end
    end

    describe '#second_latest_version' do
      it 'returns second latest mod version' do
        mv1 = create :mod_version, mod: mod, released_at: 3.days.ago
        mv2 = create :mod_version, mod: mod, released_at: 2.days.ago
        mv3 = create :mod_version, mod: mod, released_at: 1.day.ago
        mod.reload
        expect(mod.second_latest_version).to eq mv2
      end

      context 'no mod versions' do
        it 'returns nil' do
          expect(mod.second_latest_version).to eq nil
        end
      end
    end

    describe '#forum_post' do
      it { expect(mod).to respond_to :forum_post }
      it { expect(mod.build_forum_post).to be_kind_of ForumPost }

      it 'should associate with a #forum_post based on the forum_url if it can find it' do
        forum_post = create :forum_post, url: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=6742'
        mod = create :mod, forum_url: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=6742'
        forum_post.reload

        expect(mod.forum_post).to eq forum_post
        expect(forum_post.mod).to eq mod
      end
    end

    describe '#imgur' do
      it 'should save the value and return the derivated attributes' do
        mod.imgur = 'VRi7OWV'
        mod.save!
        mod.reload
        expect(mod.imgur).to eq 'VRi7OWV'
        expect(mod.imgur_url).to eq 'http://imgur.com/VRi7OWV'
        expect(mod.imgur_normal).to eq 'http://i.imgur.com/VRi7OWV.jpg'
        expect(mod.imgur_thumbnail).to eq 'http://i.imgur.com/VRi7OWVb.jpg'
        expect(mod.imgur_large_thumbnail).to eq 'http://i.imgur.com/VRi7OWVl.jpg'
      end

      it 'should extract the ID from an Imgur URL' do
        mod.imgur = 'https://i.imgur.com/5yc64LJ.png'
        mod.save!
        expect(mod.imgur).to eq '5yc64LJ'
      end

      it 'should be invalid with a non-id' do
        mod.imgur = 'ns-#$@#$'
        expect(mod).to be_invalid
      end

      it 'should be invalid with an URL other than Imgur' do
        mod.imgur = 'https://lesserimagehost.com/5yc64LJ.png'
        expect(mod).to be_invalid
      end
    end
  end

  describe 'scopes' do
    describe '.filter_by_category' do
      it 'should filter results by category' do
        mod1 = create(:mod)
        mod2 = create(:mod)
        mod2.categories = [mod1.categories[0]]
        mod2.save!
        mod3 = create(:mod)
        Mod.filter_by_category(mod1.categories[0]).all.should eq [mod1, mod2]
      end
    end

    describe '.filter_by_game_version' do
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

        expect(Mod.filter_by_game_version(gv1)).to eq [mod1, mod3]
        expect(Mod.filter_by_game_version(gv2)).to eq [mod1, mod2, mod3]
        expect(Mod.filter_by_game_version(gv3)).to eq [mod2, mod3, mod4]
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

        expect(Mod.filter_by_game_version(gv1)).to match [m1]
        expect(Mod.filter_by_game_version(gv2)).to match [m1, m2]
        expect(Mod.filter_by_game_version(gv3)).to match [m2, m3]
      end
    end

    describe '.sort_by_most_recent' do
      context 'there are no mods' do
        it 'should return empty' do
          Mod.sort_by_most_recent.all.should be_empty
        end
      end

      context 'there are some mods' do
        it 'should return them by versions#released_at date' do
          mod1 = create(:mod)
          mod2 = create(:mod)
          mod3 = create(:mod)
          create(:mod_version, released_at: 2.day.ago, mod: mod1)
          create(:mod_version, released_at: 1.day.ago, mod: mod2)
          create(:mod_version, released_at: 3.day.ago, mod: mod3)

          Mod.sort_by_most_recent.all.should eq [mod2, mod1, mod3]
        end
      end

      context 'multiple versions of the same mod' do
        it 'shuold return only one copy of each mod in the correct order' do
          mod1 = create(:mod)
          mod2 = create(:mod)
          mod3 = create(:mod)
          create :mod_version, released_at: 3.days.ago, mod: mod1
          create :mod_version, released_at: 1.days.ago, mod: mod1
          create :mod_version, released_at: 2.days.ago, mod: mod2
          create :mod_version, released_at: 4.days.ago, mod: mod3

          Mod.sort_by_most_recent.all.should eq [mod1, mod2, mod3]
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

    describe '.filter_by_search_query' do
      it 'should search on the mod name' do
        m1 = create(:mod, name: 'This is a potato simulator')
        m2 = create(:mod, name: 'This is a banana simulator')
        m3 = create(:mod, name: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('banana')).to eq [m2]
      end

      it 'should search with any case' do
        m1 = create(:mod, name: 'This is a potato simulator')
        m2 = create(:mod, name: 'This is a BaNaNAnana simulator')
        m3 = create(:mod, name: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('BaNaNa')).to eq [m2]
      end

      it 'should search on the mod summary' do
        m1 = create(:mod, summary: 'This is a potato simulator')
        m2 = create(:mod, summary: 'This is a BaNaNAnana simulator')
        m3 = create(:mod, summary: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('banana')).to eq [m2]
      end

      it 'should search on the mod description' do
        m1 = create(:mod, description: 'This is a potato simulator')
        m2 = create(:mod, description: 'This is a BaNaNAnana simulator')
        m3 = create(:mod, description: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('banana')).to eq [m2]
      end

      # context 'find on name, summary and description' do
      #   it 'should return them with name > summary > description precedence' do
      #     m1 = create(:mod, summary: 'This is a bananaFace! simulator')
      #     m2 = create(:mod, name: 'This is a BaNaNAnana simulator')
      #     m3 = create(:mod, description: 'This is a bananarama simulator')

      #     expect(Mod.filter_by_search_query('banana')).to eq [m2, m1, m3]
      #   end
      # end

      context 'using other scopes' do
        it 'should work when filtering by version' do
          m1 = create(:mod, name: 'potato 1')
          m2 = create(:mod, name: 'potato 2')
          m3 = create(:mod, name: 'banana 2')
          gv1 = create :game_version
          gv2 = create :game_version
          mv1 = create :mod_version, game_versions: [gv1], mod: m1
          mv2 = create :mod_version, game_versions: [gv2], mod: m2
          mv3 = create :mod_version, game_versions: [gv2], mod: m3

          expect(Mod.filter_by_game_version(gv2).filter_by_search_query('potato')).to eq [m2]
        end

        it 'should work when filtering by category' do
          c1 = create(:category)
          c2 = create(:category)
          m1 = create(:mod, name: 'manzana 1', categories: [c1])
          m2 = create(:mod, name: 'potato 1', categories: [c1])
          m3 = create(:mod, name: 'potato 2', categories: [c2])

          expect(Mod.filter_by_category(c1).filter_by_search_query('potato')).to eq [m2]
        end

        # context 'sorting alphabetically' do
        #   it 'search should take precedence to alphabeticallity' do
        #     m1 = create(:mod, name: 'C Potato')
        #     m2 = create(:mod, name: 'B Potato')
        #     m3 = create(:mod, name: 'A Potato')
        #     m4 = create(:mod, summary: 'B Potatou', name: 'B1')
        #     m5 = create(:mod, summary: 'A Potatou', name: 'A1')
        #     m6 = create(:mod, summary: 'C Potatou', name: 'C1')
        #     m7 = create(:mod, description: 'A Potatoeiu', name: 'A2')
        #     m8 = create(:mod, description: 'C Potatoeiu', name: 'C2')
        #     m9 = create(:mod, description: 'B Potatoeiu', name: 'B2')

        #     expect(Mod.sort_by_alpha.filter_by_search_query('potato')).to eq [m3, m2, m1, m5, m4, m6, m7, m9, m8]
        #   end
        # end

        # it 'should work when sorting by recently updated' do
        #   m1 = create(:mod, name: 'C Potato', versions: [build(:mod_version, released_at: 9.days.ago)])
        #   m2 = create(:mod, name: 'B Potato', versions: [build(:mod_version, released_at: 8.days.ago)])
        #   m3 = create(:mod, name: 'A Potato', versions: [build(:mod_version, released_at: 7.days.ago)])
        #   m4 = create(:mod, summary: 'B Potatou', versions: [build(:mod_version, released_at: 5.days.ago)])
        #   m5 = create(:mod, summary: 'A Potatou', versions: [build(:mod_version, released_at: 4.days.ago)])
        #   m6 = create(:mod, summary: 'C Potatou', versions: [build(:mod_version, released_at: 6.days.ago)])
        #   m7 = create(:mod, description: 'A Potatoeiu', versions: [build(:mod_version, released_at: 1.days.ago)])
        #   m8 = create(:mod, description: 'C Potatoeiu', versions: [build(:mod_version, released_at: 3.days.ago)])
        #   m9 = create(:mod, description: 'B Potatoeiu', versions: [build(:mod_version, released_at: 2.days.ago)])

        #   expect(Mod.sort_by_most_recent.filter_by_search_query('potato')).to eq [m3, m2, m1, m5, m4, m6, m7, m9, m8]
        # end

        # it 'should work when sorting by comments' do

        # end

        # it 'should work when sorting by most downloaded' do

        # end
      end
    end
  end
end