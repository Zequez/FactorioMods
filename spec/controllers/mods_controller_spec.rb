require 'rails_helper'

RSpec.describe ModsController, type: :controller do

  subject(:mods) do
    mods = mods || begin []
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

  describe "GET 'index'" do
    it 'should assign all the categories to @categories' do
      get 'index'
      expect(assigns(:categories)).to match Category.all
    end

    context 'no categories, no sorting' do
      before(:each) { mods }
      before(:each) { get 'index' }

      it { expect(response).to be_success }
      it { expect(response).to render_template 'index' }
      it { expect(assigns(:mods)).to eq Mod.sort_by_most_recent }
    end

    context 'with existing category' do
      before(:each) { mods }
      before(:each) { get 'index', category_id: mods.first.category.to_param }

      it { expect(response).to be_success }
      it { expect(response).to render_template 'index' }
      it { expect(assigns(:category)).to eq mods.first.category }
      it { expect(assigns(:mods)).to match_array Mod.sort_by_most_recent.in_category(mods.first.category) }
    end

    context 'with a non-existant category' do
      context "the category_id doesn't match a mod_id" do
        before(:each) { get 'index', category_id: 'banana-split' }
        it { expect(response.status).to eq 404 }
        it { expect(response).to render_template 'errors/404' }
      end

      context 'the category_id matches a mod_id' do
        before(:each) { get 'index', category_id: mods.first.to_param }
        it { expect(response).to redirect_to "/mods/#{mods.first.category.to_param}/#{mods.first.to_param}" }
        it { expect(response.status).to eq 301 }
      end
    end

    context 'with sorting, no categories' do
      context ':alpha sorting' do
        before(:each) { mods }
        before(:each) { get 'index', sort: :alpha } # :alpha gets converted to a string. What the actual fuck Rails??
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
        before(:each) { get 'index', sort: :forum_comments }
        it { expect(response).to be_success }
        it { expect(assigns(:mods)).to match Mod.sort_by_forum_comments }
        it { expect(response).to render_template 'index' }
      end

      context ':downlaods sorting' do
        before(:each) { mods }
        before(:each) { get 'index', sort: :downloads }
        it { expect(response).to be_success }
        it { expect(assigns(:mods)).to match Mod.sort_by_downloads }
        it { expect(response).to render_template 'index' }
      end
    end

    context 'with query' do
      context 'no categories, no sorting' do
        before(:each) { mods }
        before(:each) { get 'index', q: 'potato' }

        it { expect(response).to be_success }
        it { expect(response).to render_template 'index' }
        it { expect(assigns(:mods)).to eq Mod.sort_by_most_recent }
      end
    end
  end

  describe "GET 'show'" do
    context 'finds the mod' do
      before(:each) { get 'show', category_id: mod.category.to_param, id: mod.to_param }

      it { expect(response).to be_success }
      it { expect(response).to render_template 'show' }
      it { expect(assigns(:mod)).to eq mod }
    end

    context "doesn't find the mod" do
      before(:each) { get 'show', category_id: 'banana', id: 'split' }

      it { expect(response.status).to eq 404 }
      it { expect(response).to render_template 'errors/404' }
    end
  end

end
