describe API::CategoriesController, type: :controller do
  describe 'GET index' do
    it 'should return all the categories' do
      categories = 10.times.map{ create :category }
      get :index
      serialized_categories = categories.map{|c| JSON.parse CategorySerializer.new(c).to_json}
      expect(response_json).to eq serialized_categories
    end
  end

  describe 'GET show' do
    it 'should return the category by the slug' do
      c = create :category, name: 'Potato'
      get :show, id: 'potato'
      expect(response_json).to eq JSON.parse CategorySerializer.new(c).to_json
    end

    it 'should return a :not_found with a non-existant category' do
      get :show, id: 'iarstneirsaotnrsa'
      expect(response).to have_http_status :not_found
      expect(response_json).to eq("message" => "Not Found")
    end
  end
end
