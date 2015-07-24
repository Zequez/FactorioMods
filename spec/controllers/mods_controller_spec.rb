require 'rails_helper'

describe ModsController, type: :controller do
  include Devise::TestHelpers

  subject(:mods) do
    mods = mods || begin
      mods = []
      mods << create(:mod)
      mods << create(:mod)
      mods << create(:mod)
      mods << create(:mod)
      mods << create(:mod)
      mods << create(:mod)
      mods << create(:mod)
      mods
    end
  end

  subject(:mod) do
    create(:mod)
  end

  def get_index(options = {})
    options.reverse_merge! sort: :alpha

    get 'index', options
  end

  describe "get_index" do
    context 'pagination, 25 mods' do
      it 'should load the first 20 mods on the first page' do
        first_page_mods = 20.times.map{ create :mod }
        second_page_mods = 5.times.map{ create :mod }
        get_index sort: :alpha
        expect(response).to be_success
        expect(response).to render_template 'index'
        expect(assigns(:mods)).to match first_page_mods
      end

      it 'should load the last 5 mods on the second page' do
        first_page_mods = 20.times.map{ create :mod }
        second_page_mods = 5.times.map{ create :mod }
        get_index sort: :alpha, page: 2
        expect(response).to be_success
        expect(response).to render_template 'index'
        expect(assigns(:mods)).to match_array second_page_mods
      end
    end

    it 'should assign all the categories to @categories' do
      get_index
      create :category
      create :category
      create :game_version, is_group: true
      create :game_version
      create :game_version, is_group: true
      expect(assigns(:categories)).to match Category.order_by_mods_count.order_by_name
      expect(assigns(:game_versions)).to match GameVersion.sort_by_newer_to_older.all
    end

    context 'no categories, no sorting' do
      before(:each) { mods }
      before(:each) { get_index }

      it { expect(response).to be_success }
      it { expect(response).to render_template 'index' }
      it { expect(assigns(:mods)).to match_array Mod.all }
    end

    context 'with existing category' do
      before(:each) { mods }
      before(:each) { get_index category_id: mods.first.categories.first.to_param }

      it { expect(response).to be_success }
      it { expect(response).to render_template 'index' }
      it { expect(assigns(:category)).to eq mods.first.categories.first }
      it { expect(assigns(:mods)).to match_array Mod.filter_by_category(mods.first.categories.first) }
    end

    context 'with a non-existant category' do
      context "the category_id doesn't match a mod_id" do
        before(:each) { get_index category_id: 'banana-split' }
        it { expect(response.status).to eq 404 }
      end
    end

    context 'with sorting, no categories' do
      context ':alpha sorting' do
        before(:each) { mods }
        before(:each) { get_index sort: :alpha } # :alpha gets converted to a string. What the actual fuck Rails??
        it { expect(response).to be_success }
        it { expect(response).to render_template 'index' }
        it { expect(assigns(:mods)).to match_array Mod.sort_by_alpha }
      end

      context ':forum_comments sorting' do
        before(:each) do
          create(:mod, forum_comments_count: 14)
          create(:mod, forum_comments_count: 4)
          create(:mod, forum_comments_count: 6)
          create(:mod, forum_comments_count: 7)
        end
        before(:each) { get_index sort: :forum_comments }
        it { expect(response).to be_success }
        it { expect(assigns(:mods)).to match_array Mod.sort_by_forum_comments }
        it { expect(response).to render_template 'index' }
      end

      context ':downloads sorting' do
        before(:each) { mods }
        before(:each) { get_index sort: :downloads }
        it { expect(response).to be_success }
        it {
          expect(assigns(:mods)).to match_array Mod.sort_by_downloads
        }
        it { expect(response).to render_template 'index' }
      end
    end

    context 'with query' do
      context 'no categories, no sorting' do
        before(:each) do
          @m1 = create :mod, name: 'potato', versions: [build(:mod_version)]
          @m2 = create :mod, name: 'banana', versions: [build(:mod_version)]
        end
        before(:each) { get_index q: 'potato' }

        it { expect(response).to be_success }
        it { expect(response).to render_template 'index' }
        it { expect(assigns(:mods).to_a).to match Mod.sort_by_most_recent.filter_by_search_query('potato').to_a }
      end
    end

    context 'with filtering' do
      context 'with version' do
        before(:each) do
          @m1 = create :mod
          @m2 = create :mod
          @m3 = create :mod
          gv1 = create :game_version, number: '1.1.x'
          gv2 = create :game_version, number: '1.2.x'
          gv3 = create :game_version, number: '1.3.x'
          mv1 = create :mod_version, game_versions: [gv1, gv2], mod: @m1
          mv2 = create :mod_version, game_versions: [gv2, gv3], mod: @m2
          mv3 = create :mod_version, game_versions: [gv3], mod: @m3
        end

        context 'version 1.1.x' do
          before(:each) { get_index v: '1.1.x' }

          it { expect(response).to be_success }
          it { expect(response).to render_template 'index' }
          it { expect(assigns(:mods)).to match_array [@m1] }
        end

        context 'version 1.2.x' do
          before(:each) { get_index v: '1.2.x' }

          it { expect(response).to be_success }
          it { expect(response).to render_template 'index' }
          it { expect(assigns(:mods)).to match_array [@m1, @m2] }
        end

        context 'version 1.3.x' do
          before(:each) { get_index v: '1.3.x' }

          it { expect(response).to be_success }
          it { expect(response).to render_template 'index' }
          it { expect(assigns(:mods)).to match_array [@m2, @m3] }
        end
      end
    end
    
    context 'some mods non-visible' do
      it 'should not load them' do
        mods[0].update! visible: false
        mods.delete_at(0)
        mods[3].update! visible: false
        mods.delete_at(3)
        get_index
        expect(assigns(:mods)).to match_array mods
      end
    end
  end

  describe "GET 'show'" do
    context 'finds the mod' do
      before(:each) { get 'show', category_id: mod.categories.first.to_param, id: mod.to_param }

      it { expect(response).to be_success }
      it { expect(response).to render_template 'show' }
      it { expect(assigns(:mod)).to eq mod }
    end

    context "doesn't find the mod" do
      before(:each) { get 'show', id: 'split' }

      it { expect(response.status).to eq 404 }
    end
  end
  
  describe 'POST create' do  
    def submit_basic(extra_params = {})
      post :create, mod: {name: 'SuperMod', category_ids: [create(:category).id]}.merge(extra_params)
    end
    
    def submit_blank(params = {})
      post :create, params
    end

    context 'a malformed query' do
      it 'should raise a 400 error' do
        submit_blank
        expect(response).to have_http_status :bad_request
      end
    end
    
    context 'guest user (not registered)' do
      it 'should not allow it at all 401' do
        submit_blank mod: {name: 'SuperMod'}
        expect(response).to have_http_status :unauthorized
      end
    end
    
    context 'user is registered' do
      it 'should allow it to create a mod' do
        sign_in create :user
        submit_basic
        expect(response).to have_http_status :redirect
      end
      
      it 'should not allow it set #visible #owner or #slug' do
        first_user = create :user
        second_user = create :user
        sign_in first_user
        submit_basic visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq false
        expect(mod.owner).to eq first_user
        expect(mod.slug).to eq 'supermod'
      end
    end
    
    context 'user is a developer' do
      it 'should allow it set #visible but not #owner or #slug' do
        first_user = create :dev_user
        second_user = create :user
        sign_in first_user
        submit_basic visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq true
        expect(mod.owner).to eq first_user
        expect(mod.slug).to eq 'supermod'
      end
      
      it 'should also allow it to set visibility to false' do
        sign_in create(:dev_user)
        submit_basic visible: false
        expect(Mod.first.visible).to eq false
      end
    end
    
    
    context 'user is an admin' do
      it 'should allow it set #visible, #owner or #slug' do
        first_user = create :admin_user
        second_user = create :user
        sign_in first_user
        submit_basic visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq true
        expect(mod.owner).to eq second_user
        expect(mod.slug).to eq 'rsarsarsa'
      end
      
      it 'should also be able to allow those values to be default' do
        sign_in create(:admin_user)
        submit_basic visible: false, author_id: nil, slug: ''
        expect(Mod.first.visible).to eq false
        expect(Mod.first.owner).to eq nil
        expect(Mod.first.slug).to eq 'supermod'
      end
    end
  end

  
  describe "PATCH update"  do
    def submit_basic(mod, extra_params = {})
      put :update, id: mod.id, mod: extra_params
    end

    context 'a malformed query' do
      it 'should raise a 400 error' do
        user = create :user
        mod = create :mod, owner: user
        sign_in user
        patch :update, id: mod.id
        expect(response).to have_http_status :bad_request
      end
    end
    
    context 'guest user (not registered)' do
      it 'should not allow it at all 401' do
        mod = create :mod
        submit_basic mod, name: mod.name
        expect(response).to have_http_status :unauthorized
      end
    end
    
    context 'user is registered' do
      it "should allow it to update a it's own mod" do
        user = create :user
        mod = create :mod, owner: user
        sign_in user
        submit_basic mod, name: mod.name
        expect(response).to have_http_status :redirect
      end
      
      it "should not allow it to update someone elses mod" do
        user = create :user
        mod = create :mod, owner: (create :user)
        sign_in user
        submit_basic mod
        expect(response).to have_http_status :unauthorized
      end
      
      it 'should not allow it set #visible #owner or #slug' do
        first_user = create :user
        second_user = create :user
        mod = create :mod, owner: first_user
        sign_in first_user
        submit_basic mod, visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq false
        expect(mod.owner).to eq first_user
        expect(mod.slug).to eq mod.slug
      end
    end
    
    context 'user is a developer' do
      it 'should allow it set #visible but not #owner or #slug' do
        first_user = create :dev_user
        second_user = create :user
        mod = create :mod, owner: first_user
        sign_in first_user
        submit_basic mod, visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq true
        expect(mod.owner).to eq first_user
        expect(mod.slug).to eq mod.slug
      end
      
      it 'should not allow it to update someone elses mod' do
        first_user = create :dev_user
        second_user = create :user
        mod = create :mod, owner: second_user
        sign_in first_user
        submit_basic mod, visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :unauthorized
      end
      
      it 'should not allow it to update a mod without owner' do
        first_user = create :dev_user
        mod = create :mod, owner: nil
        sign_in first_user
        submit_basic mod, visible: true, author_id: first_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :unauthorized
      end
      
      it 'should also allow it to set visibility to false' do
        user = create(:dev_user)
        sign_in user
        mod = create :mod, owner: user
        submit_basic mod, visible: false
        expect(Mod.first.visible).to eq false
      end
    end
    
    context 'user is an admin' do
      it 'should allow it set #visible, #owner or #slug' do
        first_user = create :admin_user
        second_user = create :user
        mod = create :mod, owner: first_user
        sign_in first_user
        submit_basic mod, visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq true
        expect(mod.owner).to eq second_user
        expect(mod.slug).to eq 'rsarsarsa'
      end
      
      it 'should also be able to allow those values to be default' do
        user = create(:admin_user)
        mod = create :mod, owner: user
        sign_in user
        submit_basic mod, visible: false, author_id: nil, slug: ''
        expect(Mod.first.visible).to eq false
        expect(Mod.first.owner).to eq nil
        expect(Mod.first.slug).to eq mod.slug
      end
      
      it 'should also allow it to modify a mod with any owner' do
        first_user = create :admin_user
        second_user = create :user
        mod = create :mod, owner: second_user
        sign_in first_user
        submit_basic mod, visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq true
        expect(mod.owner).to eq second_user
        expect(mod.slug).to eq 'rsarsarsa'
      end
      
      it 'should not allow it to update a mod without owner' do
        first_user = create :admin_user
        second_user = create :user
        mod = create :mod, owner: nil
        sign_in first_user
        submit_basic mod, visible: true, author_id: second_user.id, slug: 'rsarsarsa'
        expect(response).to have_http_status :redirect
        mod = Mod.first
        expect(mod.visible).to eq true
        expect(mod.owner).to eq second_user
        expect(mod.slug).to eq 'rsarsarsa'
      end
    end
  end
end
