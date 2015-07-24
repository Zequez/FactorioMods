require 'rails_helper'

describe ModDecorator do
  def create_decorated(*args)
    create(*args).decorate
  end
  
  describe '#authors_links_list' do
    it 'should return a comma separated authors list links' do
      mod = create_decorated :mod, authors: 3.times.map{ |i| create :user, name: "Au#{i}" }
      expect(mod.authors_links_list).to eq '<a href="/users/au0">Au0</a>, <a href="/users/au1">Au1</a>, <a href="/users/au2">Au2</a>'
    end

    it 'should add the (maintainer) text if the author is also the owner' do
      authors = 3.times.map{ |i| create :user, name: "Au#{i}" }
      mod = create_decorated :mod, authors: authors, owner: authors[1]
      expect(mod.authors_links_list).to eq '<a href="/users/au0">Au0</a>, <a href="/users/au1">Au1</a> (maintainer), <a href="/users/au2">Au2</a>'
    end

    it 'should not add the (maintainer) text if there is only 1 author' do
      author = create :user, name: "Au0"
      mod = create_decorated :mod, authors: [author], owner: author
      expect(mod.authors_links_list).to eq '<a href="/users/au0">Au0</a>'
    end

    it 'should return N/A if the mod has no authors associated' do
      mod = create_decorated :mod, authors: []
      expect(mod.authors_links_list).to eq 'N/A'
    end
  end
  
  describe '#forum_link' do
    context 'only has forum post URL' do
      it 'should only have the forum URL' do
        mod = create_decorated :mod, forum_url: 'http://potato.com'
        expect(URI.extract(mod.forum_link)).to eq ['http://potato.com']
      end
    end
    
    context 'has only the subforum URL' do
      it 'should link to the subforum' do
        mod = create_decorated :mod, subforum_url: 'http://cabbage.com'
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
      mod_file = create :mod_file, mod_version: mod_version
      mod = Mod.first.decorate
      expect(mod.has_files?).to eq true
    end
  end
end