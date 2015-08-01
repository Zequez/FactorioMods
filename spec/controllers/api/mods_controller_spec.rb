require 'rails_helper'

describe API::ModsController, type: :controller do
  def serialized(mod)
    if mod.kind_of? Mod
      JSON.parse ModSerializer.new(mod).to_json
    else
      mod.map{|m| serialized(m)}
    end
  end

  before :each do
    c1 = create :category, name: 'Potato'
    c2 = create :category, name: 'Apple'
    c3 = create :category, name: 'Banana'

    @mods = []
    @mods.push create :mod, name: 'Aaa', info_json_name: 'aa', categories: [c1, c2]
    @mods.push create :mod, name: 'Bbb', info_json_name: 'bb', categories: [c1]
    @mods.push create :mod, name: 'Ccc', info_json_name: 'cc', categories: [c2, c3]
    @mods.push create :mod, name: 'Ddd', info_json_name: 'dd', categories: [c2]
    @mods.push create :mod, name: 'Eee', info_json_name: 'ee', categories: [c1,c2,c3]
  end

  describe 'GET index' do
    it 'should return a list of mods JSON encoded' do
      get :index
      mods = Mod.sort_by(:alpha).all
      expect(response_json).to eq serialized(mods)
    end

    context 'searching' do
      it 'should return the matching mods' do
        get :index, q: 'cc'
        expect(response_json).to eq serialized([@mods[2]])
      end
    end

    context 'within category' do
      it 'should return the matching mods' do
        get :index, category: 'apple'
        expect(response_json).to eq serialized([@mods[0], @mods[2], @mods[3], @mods[4]])
      end
    end

    context 'from a list of names' do
      it 'should return the matching mods' do
        get :index, names: 'aa,bb,dd'
        expect(response_json).to eq serialized([@mods[0], @mods[1], @mods[3]])
      end
    end

    context 'from a list of ids' do
      it 'should return the matching mods' do
        get :index, ids: [@mods[2],@mods[3]].map(&:id).join(',')
        expect(response_json).to eq serialized([@mods[2], @mods[3]])
      end
    end

    context 'from the second page' do
      it 'should be empty with not enough mods' do
        get :index, page: 2
        expect(response_json).to eq serialized([])
      end

      it 'should have some mods if there are more than 50' do
        create_list :mod, 50
        get :index, page: 2
        expect(response_json.size).to eq 5
      end
    end

    context 'from a specific author' do
      pending
    end
  end

  describe 'GET show' do
    it 'should return the mod by name' do
      get :show, id: 'cc'
      expect(response_json).to eq serialized(@mods[2])
    end

    it 'should return a :not_found with a non-existant mod' do
      get :show, id: 'iarstneirsaotnrsa'
      expect(response).to have_http_status :not_found
      expect(response_json).to eq("message" => "Not Found")
    end
  end
end
