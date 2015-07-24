require 'rails_helper'
include Warden::Test::Helpers

feature 'Display an index of mods in certain order' do
  def create_mod(name, last_version, forum_views)
    forum_post = forum_views ? create(:forum_post, views_count: forum_views) : nil
    mod = build :mod, name: name, forum_post: forum_post
    if last_version
      mod.versions = [build(:mod_version, released_at: last_version, mod: nil)]
    end
    mod.save!
    mod
  end

  # Describe how the mod index should work
  RSpec.shared_examples 'mod index' do
    context 'with multiple mods' do
      before(:each) do
        @mods = []
        @mods << create_mod('SuperMod2', 2.days.ago, 1000)
        @mods << create_mod('SuperMod4', 5.days.ago, 800)
        @mods << create_mod('superMod0', 10.days.ago, 1200)
        @mods << create_mod('SuperMod6', 1.days.ago, 1500)
        @mods << create_mod('superMod3', 7.days.ago, 100)
      end

      scenario 'visit the front page and sort by recently updated' do
        visit '/'
        expect(mod_names).to eq %w{SuperMod6 SuperMod2 SuperMod4 superMod3 superMod0}
      end

      scenario 'sort by recently updated' do
        visit '/recently-updated'
        expect(mod_names).to eq %w{SuperMod6 SuperMod2 SuperMod4 superMod3 superMod0}
      end

      scenario 'sort by alpha' do
        visit '/mods'
        expect(mod_names).to eq %w{superMod0 SuperMod2 superMod3 SuperMod4 SuperMod6}
      end

      scenario 'sort by most popular' do
        visit '/most-popular'
        expect(mod_names).to eq %w{SuperMod6 superMod0 SuperMod2 SuperMod4 superMod3}
      end
      
      scenario 'some mods are not visible' do
        @mods[2].update! visible: false
        @mods[4].update! visible: false
        visit '/mods'
        expect(mod_names).to eq %w{SuperMod2 SuperMod4 SuperMod6}
      end
    end

    context 'special cases' do
      scenario 'when sorting by release date, mods without mod_version should also be included' do
        create_mod 'SuperMod1', nil, 200
        create_mod 'SuperMod2', 5.days.ago, 100
        visit '/recently-updated'
        expect(mod_names).to eq %w{SuperMod2 SuperMod1}
      end

      scenario 'when sorting by most popular, mods without forum_post should also be included' do
        create_mod 'SuperMod1', 1.days.ago, nil
        create_mod 'SuperMod2', 1.days.ago, 100
        visit '/most-popular'
        expect(mod_names).to eq %w{SuperMod2 SuperMod1}
      end
    end
  end
  
  # Test those examples for both HTML and JSON
  context 'when requesting HTML' do
    it_behaves_like 'mod index' do
      def mod_names
        page.all('.mod-title').map(&:text)
      end
    end
  end
  
  context 'when requesting JSON', driver: :rack_test_json do
    it_behaves_like 'mod index' do
      def mod_names
        JSON.parse(last_response).map { |hash| hash["name"] }
      end
    end
  end

  context 'with many authors' do
    scenario 'Mod with multiple authors and no owner' do
      authors = 5.times.map{ |i| create :user, name: "Au#{i}" }
      create :mod, name: 'SuperMod', authors: authors
      visit '/'
      expect(page).to have_content /Au0.*Au1.*Au2.*Au3.*Au4/
      expect(page).to have_link 'Au0', '/users/au0'
      expect(page).to have_link 'Au1', '/users/au1'
      expect(page).to have_link 'Au2', '/users/au2'
      expect(page).to have_link 'Au3', '/users/au3'
      expect(page).to have_link 'Au4', '/users/au4'
    end

    scenario 'Mod with multiple authors and one of the authors is the owner' do
      authors = 5.times.map{ |i| create :user, name: "Au#{i}" }
      create :mod, name: 'SuperMod', authors: authors, owner: authors[1]
      visit '/'
      expect(page).to have_content /Au0.*Au1.*(maintainer).*Au2.*Au3.*Au4/
    end

    scenario 'Mod with multiple authors with reversed sorting order' do
      authors = 5.times.map{ |i| create :user, name: "Au#{i}" }
      mod = create :mod, name: 'SuperMod', authors: authors
      mod.authors_mods[0].update_column :sort_order, 5
      mod.authors_mods[1].update_column :sort_order, 4
      mod.authors_mods[2].update_column :sort_order, 3
      mod.authors_mods[3].update_column :sort_order, 2
      mod.authors_mods[4].update_column :sort_order, 1
      visit '/'
      expect(page).to have_content /Au4.*Au3.*Au2.*Au1.*Au0/
    end
  end
end
