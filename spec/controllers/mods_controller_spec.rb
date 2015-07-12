require 'rails_helper'

RSpec.describe ModsController, type: :controller do

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
        it { expect(assigns(:mods)).to match Mod.sort_by_alpha }
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
        it { expect(assigns(:mods)).to match Mod.sort_by_forum_comments }
        it { expect(response).to render_template 'index' }
      end

      context ':downloads sorting' do
        before(:each) { mods }
        before(:each) { get_index sort: :downloads }
        it { expect(response).to be_success }
        it { expect(assigns(:mods)).to match Mod.sort_by_downloads }
        it { expect(response).to render_template 'index' }
      end
    end

    context 'with query' do
      context 'no categories, no sorting' do
        before(:each) do
          @m1 = create :mod, name: 'potato', versions: [create(:mod_version)]
          @m2 = create :mod, name: 'banana', versions: [create(:mod_version)]
        end
        before(:each) { get_index q: 'potato' }

        it { expect(response).to be_success }
        it { expect(response).to render_template 'index' }
        it { expect(assigns(:mods)).to eq Mod.sort_by_most_recent.filter_by_search_query('potato') }
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
end
