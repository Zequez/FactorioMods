require 'rails_helper'

describe API::ModsController, type: :controller do
  describe 'GET index' do
    before :each do
      @mods = []
      @mods.push create :mod, name: 'aa'
      @mods.push create :mod, name: 'bb'
      @mods.push create :mod, name: 'cc'
      @mods.push create :mod, name: 'dd'
      @mods.push create :mod, name: 'ee'
    end

    it 'should return a list of mods JSON encoded' do
      get :index
      expect(response_json).to eq JSON.parse @mods.to_json
    end
  end
end
