describe ModDecorator do
  def create_decorated(*args)
    create(*args).decorate
  end

  describe '#authors_links_list' do
    it 'should return a comma separated authors list links' do
      mod = create_decorated :mod, authors: 3.times.map{ |i| create :author, name: "Au#{i}" }
      expect(mod.authors_links_list).to eq '<a href="/authors/au0">Au0</a>, <a href="/authors/au1">Au1</a>, <a href="/authors/au2">Au2</a>'
    end

    it 'should add the (maintainer) text if the author is also the owner' do
      authors = 3.times.map{ |i| create :author, name: "Au#{i}" }
      user = create :user
      authors[1].update! user: user
      mod = create_decorated :mod, authors: authors, owner: user
      expect(mod.authors_links_list).to eq '<a href="/authors/au0">Au0</a>, <a href="/authors/au1">Au1</a> (maintainer), <a href="/authors/au2">Au2</a>'
    end

    it 'should not add the (maintainer) text if there is only 1 author' do
      user = create :user
      author = create :author, name: "Au0", user: user
      mod = create_decorated :mod, authors: [author], owner: user
      expect(mod.authors_links_list).to eq '<a href="/authors/au0">Au0</a>'
    end

    it 'should return N/A if the mod has no authors associated' do
      mod = create_decorated :mod, authors: []
      expect(mod.authors_links_list).to eq 'N/A'
    end

    it 'should show them in the correct sorting order' do
      authors = 3.times.map{ |i| create :author, name: "Au#{i}" }
      mod = create :mod, name: 'SuperMod', authors: authors
      mod.authors_mods[0].update_column :sort_order, 3
      mod.authors_mods[1].update_column :sort_order, 2
      mod.authors_mods[2].update_column :sort_order, 1
      mod.reload
      expect(mod.decorate.authors_links_list).to eq '<a href="/authors/au2">Au2</a>, <a href="/authors/au1">Au1</a>, <a href="/authors/au0">Au0</a>'
    end

    it 'should not add maintainer if both the author user and the mod owner are nil' do
      authors = 3.times.map{ |i| create :author, name: "Au#{i}" }
      create :user
      mod = create_decorated :mod, authors: authors, owner: nil
      expect(mod.authors_links_list).to eq '<a href="/authors/au0">Au0</a>, <a href="/authors/au1">Au1</a>, <a href="/authors/au2">Au2</a>'
    end
  end

  describe '#forum_link' do
    context 'only has forum post URL' do
      it 'should only have the forum URL' do
        mod = create_decorated :mod, forum_url: 'http://potato.com'
        expect(URI.extract(mod.forum_link)).to eq ['http://potato.com']
      end

      it 'should only have the forum URL, with empty string subforum_url' do
        mod = create_decorated :mod, forum_url: 'http://potato.com', subforum_url: ''
        expect(URI.extract(mod.forum_link)).to eq ['http://potato.com']
      end
    end

    context 'has only the subforum URL' do
      it 'should link to the subforum' do
        mod = create_decorated :mod, subforum_url: 'http://cabbage.com'
        expect(URI.extract(mod.forum_link)).to eq ['http://cabbage.com']
      end

      it 'should link to the subforum, with empty string forum post URL' do
        mod = create_decorated :mod, subforum_url: 'http://cabbage.com', forum_url: ''
        expect(URI.extract(mod.forum_link)).to eq ['http://cabbage.com']
      end
    end

    context 'has both the subforum and the forum post URL' do
      it 'should link to both' do
        mod = create_decorated :mod, forum_url: 'http://potato.com', subforum_url: 'http://cabbage.com'
        expect(URI.extract(mod.forum_link)).to eq ['http://cabbage.com', 'http://potato.com']
      end
    end
  end

  describe '#github_link' do
    it 'should return a link to the project Github URL if available' do
      mod = create_decorated(:mod, github: 'potato/salad')
      expect(mod.github_link).to eq '<a href="http://github.com/potato/salad">http://github.com/potato/salad</a>'
    end

    it 'should return N/A if #github_path not present' do
      mod = create_decorated(:mod, github: '')
      expect(mod.github_link).to eq 'N/A'
    end
  end

  describe '#has_versions?' do
    it 'should return false if the mod has no versions' do
      mod = create_decorated :mod, versions: []
      expect(mod.has_versions?).to eq false
    end

    it 'should return true if the mod has a version' do
      mod = create :mod, versions: []
      create :mod_version, mod: mod
      mod = Mod.first.decorate
      expect(mod.has_versions?).to eq true
    end
  end

  describe '#has_files?' do
    it 'should return false if the mod has no files' do
      mod = create_decorated :mod, versions: []
      expect(mod.has_files?).to eq false
    end

    it 'should return true if the mod has at least a file' do
      mod = build :mod, versions: []
      mod.save!
      mod_version = create :mod_version, mod: mod
      create :mod_file, mod_version: mod_version
      mod = Mod.first.decorate
      expect(mod.has_files?).to eq true
    end
  end

  describe '#install_protocol_url' do
    it 'should return the factoriomods:// protocol with the JSON-encoded mod' do
      mod = create(:mod)
      encoded_json = Base64.strict_encode64 ModSerializer.new(mod).to_json
      expect(mod.decorate.install_protocol_url).to eq "factoriomods://#{encoded_json}"
    end

    it 'should accept an argument with the intended version' do
      mod = create(:mod)
      mv = create :mod_version, mod: mod
      create :mod_version, mod: mod
      encoded_json = Base64.strict_encode64 ModSerializer.new(mod, versions: [mv]).to_json
      expect(mod.decorate.install_protocol_url(mv)).to eq "factoriomods://#{encoded_json}"
    end
  end
end
