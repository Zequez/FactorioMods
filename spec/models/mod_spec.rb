describe Mod do
  describe 'attributes' do
    subject(:mod) { build :mod }

    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :description }
    it { is_expected.to respond_to :summary }

    it { is_expected.to respond_to :github }
    it { is_expected.to respond_to :github_url }
    it { is_expected.to respond_to :license }
    it { is_expected.to respond_to :additional_contributors }
    it { is_expected.to respond_to :author_name }

    it { is_expected.to respond_to :first_version_date }
    it { is_expected.to respond_to :last_version_date }

    it { is_expected.to respond_to :media_links }
    it { is_expected.to respond_to :imgur }
    it { is_expected.to respond_to :imgur_url }
    it { is_expected.to respond_to :imgur_thumbnail }
    it { is_expected.to respond_to :imgur_normal }

    it { is_expected.to respond_to :last_release_date }
    it { is_expected.to respond_to :visible? }
    it { expect(mod.visible).to eq true }
    it { is_expected.to respond_to :contact }
    it { is_expected.to respond_to :info_json_name }
    it { is_expected.to respond_to :bookmarks_count }

    # URLs
    it { is_expected.to respond_to :license_url }
    it { is_expected.to respond_to :official_url }
    it { is_expected.to respond_to :forum_url }

    # External counters
    it { is_expected.to respond_to :forum_comments_count }
    it { is_expected.to respond_to :comments_count }

    # Tracking data
    # it { is_expected.to respond_to :downloads }
    # it { is_expected.to respond_to :downloads_count }
    # it { is_expected.to respond_to :visits }
    # it { is_expected.to respond_to :visits_count }

    # belongs_to
    it { is_expected.to respond_to :owner }
    it { expect(mod.build_owner).to be_kind_of User }
    it { is_expected.to respond_to :categories }
    it { is_expected.to respond_to :last_version }
    # has_many
    it { is_expected.to respond_to :files }
    it { is_expected.to respond_to :versions }
    it { expect(mod.versions.build).to be_kind_of ModVersion }
    it { is_expected.to respond_to :bookmarks }
    it { expect(mod.bookmarks.build).to be_kind_of Bookmark }
    # it { is_expected.to respond_to :tags }
    it { is_expected.to respond_to :favorites }
    it { is_expected.to respond_to :favorites_count }
    it { is_expected.to respond_to :authors }
    it { expect(mod.authors.build).to be_kind_of Author }
    it { is_expected.to respond_to :authors_mods }
    it { expect(mod.authors_mods.build).to be_kind_of AuthorsMod }

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
        create :mod, name: 'PotatoMod'
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
        create :mod, slug: 'potato'
        mod2 = build :mod, slug: 'potato', name: 'apple' # We are forcing this slug
        expect(mod2).to be_invalid
        expect(mod2.errors[:slug].size).to eq 1
      end

      it 'should be invalid with more than 8 authors' do
        authors = 9.times.map{ create :author }
        mod = build :mod, authors: authors
        expect(mod).to be_invalid
        expect(mod.errors[:authors].size).to eq 1
      end

      it 'should be valid with 8 authors' do
        authors = 8.times.map{ create :author }
        mod = build :mod, authors: authors
        expect(mod).to be_valid
      end

      it 'should be invalid without #info_json_name' do
        mod = build :mod, info_json_name: ''
        expect(mod).to be_invalid
      end
    end

    describe '#slug' do
      it 'should slug all characters from the name' do
        mod = create :mod, name: 'Banana split canaleta cósmica "123" pepep'
        expect(mod.slug).to eq 'banana-split-canaleta-cosmica-123-pepep'
      end

      it 'should use the author name as the second part of the slug when clashing' do
        mod1 = create :mod, name: 'Potato!'
        mod2 = create :mod, name: 'Potato?', authors_list: 'Salad'
        expect(mod1.slug).to eq 'potato'
        expect(mod2.slug).to eq 'potato-by-salad'
      end

      it 'should not allow the "new" slug as it clashes with the controller action' do
        mod = create :mod, name: 'New!', authors_list: 'Potato'
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

    describe '#author_name' do
      it 'should create new author with the name' do
        mod = create :mod, author_name: 'Potato'
        expect(mod.authors.first.name).to eq 'Potato'
      end

      it 'should use an existing author if it already exists' do
        create :author, name: 'Potato Garch'
        mod = create :mod, author_name: 'potato-garch'
        expect(mod.authors.first.name).to eq 'Potato Garch'
      end

      it 'should add author#name validation error to #author_name' do
        mod = build :mod, author_name: '0-0'
        expect(mod).to be_invalid
        expect(mod.errors[:author_name].size).to be > 0
      end

      it 'should allow a blank #author_name' do
        mod = build :mod, author_name: ''
        expect(mod).to be_valid
      end

      it 'should always leave #authors with just 1 author' do
        mod = create :mod, author_name: 'Potato'
        expect(mod.authors.size).to eq 1
        expect(mod.authors.first.name).to eq 'Potato'
        mod.reload
        mod.author_name = 'Galaxy'
        mod.save!
        mod.reload
        expect(mod.authors.size).to eq 1
        expect(mod.authors.first.name).to eq 'Galaxy'
      end
    end

    describe '#authors_list' do
      it { is_expected.to respond_to :authors_list }

      it 'associate the #authors by name separated by commas' do
        create :author, name: 'Apple'
        u2 = create :author, name: 'Potato'
        u3 = create :author, name: 'Orange'
        u4 = create :author, name: 'Banana'
        mod.authors_list = 'Orange,Potato,Banana'
        mod.save!
        expect(mod.authors).to eq [u3, u2, u4]
      end

      it 'should order them correctly' do
        create :author, name: 'Apple'
        u2 = create :author, name: 'Potato'
        u3 = create :author, name: 'Orange'
        u4 = create :author, name: 'Banana'
        mod.authors_list = 'Orange,Potato,Banana'
        mod.save!
        mod = Mod.first
        expect(mod.authors).to eq [u3, u2, u4]
        mod.authors_list = 'Potato,Banana,Orange'
        mod.save!
        mod = Mod.first
        expect(mod.authors).to eq [u2, u4, u3]
      end

      it 'should work with random spaces everywhere' do
        create :author, name: 'Apple'
        u2 = create :author, name: 'Potato'
        u3 = create :author, name: 'Orange'
        u4 = create :author, name: 'Banana'
        mod.authors_list = '      Orange     , Potato , Banana         '
        mod.save!
        expect(mod.authors).to eq [u3, u2, u4]
      end

      it 'should work with different cases' do
        create :author, name: 'Apple'
        u2 = create :author, name: 'Potato'
        u3 = create :author, name: 'Orange'
        u4 = create :author, name: 'Banana'
        mod.authors_list = 'orange,potato,banana'
        mod.save!
        expect(mod.authors).to eq [u3, u2, u4]
      end

      it "should create a new author if it doesn't exist" do
        u1 = create :author, name: 'Apple'
        mod.authors_list = 'Apple,Watermelon'
        mod.save!
        u2 = Author.last
        expect(u2.name).to eq 'Watermelon'
        expect(u2.forum_name).to eq 'Watermelon'
        expect(mod.authors).to eq [u1, u2]
      end

      it 'should be invalid if the user to be generated is invalid' do
        mod.authors_list = 'Bi$cuit,1234'
        expect(mod).to be_invalid
        expect(mod.errors[:authors_list]).to eq ['1234 is invalid']
      end

      it 'should be invalid with more than 8 authors' do
        mod.authors_list = 'Apple,Potato,Watermelon,Orange,Clementine,Fennel,Banana,Melon,Strawberry'
        expect(mod).to be_invalid
        expect(mod.errors[:authors_list].first).to match(/too many authors/i)
      end

      it 'should not create the users if the validation fails' do
        mod = build :mod, authors_list: 'Apple,---,Fennel'
        expect(mod.save).to eq false
        expect(User.all).to eq [mod.owner]
      end

      it 'should ignore duplicated names and use the first apparition' do
        mod = build :mod, authors_list: 'Apple, Potato, Apple'
        expect(mod).to be_valid
        mod.save!
        expect(mod.authors.map(&:name)).to eq %w{Apple Potato}
      end

      it 'should ignore empty authors' do
        mod = build :mod, authors_list: 'Apple,,Potato'
        expect(mod).to be_valid
        mod.save!
        expect(mod.authors.map(&:name)).to eq %w{Apple Potato}
      end

      # This is some top-notch DDoS protection
      it 'should disregard everything after the tenth author' do
        mod = build :mod, authors_list: "Au0, Au1, Au2, Au4, Au5, Au6, Au7, Au8, Au9, Au10, Au11, Au12"
        expect(mod).to be_invalid
        expect(mod.authors.size).to eq 10
      end

      it 'return a list of names if called after the mod loads' do
        authors = 5.times.map{ |i| create :author, name: "Au#{i}" }
        mod = create :mod, authors: authors
        expect(mod.authors_list).to eq 'Au0, Au1, Au2, Au3, Au4'
      end
    end
  end

  describe 'builders' do
    describe '.new_for_form' do
      it 'should build the required associations and read the #forum_post' do
        gv = create :game_version
        subforum = create :subforum, game_version: gv
        forum_post = create :forum_post,
          title: 'rsarsarsarsa',
          author_name: 'GuyGuy',
          url: 'http://potatopotato.com.potato',
          published_at: 1.day.ago,
          subforum: subforum
        current_user = create :user
        mod = Mod.new_for_form(current_user, forum_post.id)
        expect(mod.versions[0]).to be_kind_of ModVersion
        expect(mod.versions[0].files[0]).to be_kind_of ModFile
        expect(mod.name).to eq 'rsarsarsarsa'
        expect(mod.authors_list).to eq 'GuyGuy'
        expect(mod.forum_url).to eq 'http://potatopotato.com.potato'
        expect(mod.versions[0].released_at).to be_within(1.second).of 1.day.ago
        expect(mod.versions[0].game_versions).to eq [gv]
        expect(mod.visible).to eq true
        expect(mod.owner).to eq current_user
      end
    end
  end

  describe 'scopes' do
    describe '.filter_by_names' do
      it 'should return a list of mods by #info_json_name' do
        mods = []
        mods.push create :mod, info_json_name: 'potato'
        create :mod, info_json_name: 'potato-2'
        mods.push create :mod, info_json_name: 'banana-stream'
        create :mod, info_json_name: 'i love this keyboard'
        mods.push create :mod, info_json_name: 'Atom by github rocks'
        found = Mod.filter_by_names 'potato,banana-stream, Atom by github rocks'
        expect(found).to match_array mods
      end

      it 'should be case sensitive' do
        create :mod, info_json_name: 'potato'
        mod = create :mod, info_json_name: 'PoTaTo'
        expect(Mod.filter_by_names('PoTaTo')).to match_array [mod]
      end

      it 'should return all the mods with the same #info_json_name' do
        mod1 = create :mod, info_json_name: 'potato'
        mod2 = create :mod, info_json_name: 'potato'
        create :mod, info_json_name: 'banana'
        expect(Mod.filter_by_names('potato')).to match_array [mod1, mod2]
      end

      it "should return the whole scope with an empty argument" do
        create :mod
        create :mod
        expect(Mod.filter_by_names('')).to eq Mod.all
      end
    end

    describe '.filter_by_ids' do
      it 'should return a list of mods by comma-separated #id' do
        m1 = create :mod
        m2 = create :mod
        create :mod
        m4 = create :mod
        expect(Mod.filter_by_ids("#{m1.id},#{m2.id},#{m4.id}")).to eq [m1,m2,m4]
      end
    end

    describe '.filter_by_category' do
      before :each do
        @cat = create :category, name: 'Potato'
        @mod1 = create :mod, categories: [@cat]
        @mod2 = create :mod, categories: [@cat]
        @mod3 = create :mod
      end

      it 'should filter results by category' do
        expect(Mod.filter_by_category(@cat)).to eq [@mod1, @mod2]
      end

      it 'should work with the category slug' do
        expect(Mod.filter_by_category('potato')).to eq [@mod1, @mod2]
      end

      it 'should raise an exception for a non-existant category' do
        expect{ Mod.filter_by_category('rsarsasrasrt') }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'should make the category available as a collection attribute' do
        mods = Mod.filter_by_category(@cat)
        expect(mods.category).to eq @cat
      end

      it 'should return the whole scope with an empty argument' do
        expect(Mod.filter_by_category('')).to match_array [@mod1, @mod2, @mod3]
      end

      it 'should make #uncategorized available with the previous scope' do
        prev_scope = Mod.where(name: 'something')
        mods = prev_scope.filter_by_category('potato')
        expect(mods.uncategorized).to eq prev_scope
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
        create :mod_version, game_versions: [gv1, gv2], mod: m1
        create :mod_version, game_versions: [gv2, gv3], mod: m2
        create :mod_version, game_versions: [gv3], mod: m3

        expect(Mod.filter_by_game_version(gv1)).to match [m1]
        expect(Mod.filter_by_game_version(gv2)).to match [m1, m2]
        expect(Mod.filter_by_game_version(gv3)).to match [m2, m3]
      end

      it 'should work by poviding the game version number' do
        m1 = create :mod
        m2 = create :mod
        m3 = create :mod
        gv1 = create :game_version, number: '1.1.x'
        gv2 = create :game_version, number: '1.2.x'
        gv3 = create :game_version, number: '1.3.x'
        create :mod_version, game_versions: [gv1, gv2], mod: m1
        create :mod_version, game_versions: [gv2, gv3], mod: m2
        create :mod_version, game_versions: [gv3], mod: m3

        expect(Mod.filter_by_game_version('1.1.x')).to match [m1]
        expect(Mod.filter_by_game_version('1.2.x')).to match [m1, m2]
        expect(Mod.filter_by_game_version('1.3.x')).to match [m2, m3]
      end

      it 'returns the whole scope when empty' do
        expect(Mod.filter_by_game_version('')).to eq Mod.all
      end

      it 'should raise an exception for a non-existant game version' do
        expect{ Mod.filter_by_game_version('1.1.1.2.3') }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'should make the game version available on the collection' do
        m1 = create :mod
        gv1 = create :game_version, number: '1.1.x'
        create :mod_version, game_versions: [gv1], mod: m1
        mods = Mod.filter_by_game_version('1.1.x')
        expect(mods.game_version).to eq gv1
      end
    end

    describe 'sorting' do
      describe '.sort_by' do
        it 'should work with :alpha' do
          expect(Mod).to receive(:sort_by_alpha)
          Mod.sort_by(:alpha)
        end

        it 'should work with :most_recent' do
          expect(Mod).to receive(:sort_by_most_recent)
          Mod.sort_by(:most_recent)
        end

        it 'should work with :popular' do
          expect(Mod).to receive(:sort_by_popular)
          Mod.sort_by(:popular)
        end

        it 'should work with :forum_comments' do
          expect(Mod).to receive(:sort_by_forum_comments)
          Mod.sort_by(:forum_comments)
        end

        it 'should work with :downloads' do
          expect(Mod).to receive(:sort_by_downloads)
          Mod.sort_by(:downloads)
        end

        it 'should add #sorted_by to the scope methods' do
          expect(Mod.sort_by(:alpha).sorted_by).to eq :alpha
          expect(Mod.sort_by(:most_recent).sorted_by).to eq :most_recent
          expect(Mod.sort_by(:popular).sorted_by).to eq :popular
          expect(Mod.sort_by(:forum_comments).sorted_by).to eq :forum_comments
          expect(Mod.sort_by(:downloads).sorted_by).to eq :downloads
          expect(Mod.sort_by('').sorted_by).to eq :alpha
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
    end

    describe '.filter_by_search_query' do
      it 'should search on the mod name' do
        create(:mod, name: 'This is a potato simulator')
        m2 = create(:mod, name: 'This is a banana simulator')
        create(:mod, name: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('banana')).to eq [m2]
      end

      it 'should search with any case' do
        create(:mod, name: 'This is a potato simulator')
        m2 = create(:mod, name: 'This is a BaNaNAnana simulator')
        create(:mod, name: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('BaNaNa')).to eq [m2]
      end

      it 'should search on the mod summary' do
        create(:mod, summary: 'This is a potato simulator')
        m2 = create(:mod, summary: 'This is a BaNaNAnana simulator')
        create(:mod, summary: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('banana')).to eq [m2]
      end

      it 'should search on the mod description' do
        create(:mod, description: 'This is a potato simulator')
        m2 = create(:mod, description: 'This is a BaNaNAnana simulator')
        create(:mod, description: 'This is a coffee simulator')

        expect(Mod.filter_by_search_query('banana')).to eq [m2]
      end

      it 'should return the whole scope with an empty query' do
        create(:mod, description: 'This is a potato simulator')
        expect(Mod.filter_by_search_query('')).to eq Mod.all
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
          create :mod_version, game_versions: [gv1], mod: m1
          create :mod_version, game_versions: [gv2], mod: m2
          create :mod_version, game_versions: [gv2], mod: m3

          expect(Mod.filter_by_game_version(gv2).filter_by_search_query('potato')).to eq [m2]
        end

        it 'should work when filtering by category' do
          c1 = create(:category)
          c2 = create(:category)
          create(:mod, name: 'manzana 1', categories: [c1])
          m2 = create(:mod, name: 'potato 1', categories: [c1])
          create(:mod, name: 'potato 2', categories: [c2])

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
