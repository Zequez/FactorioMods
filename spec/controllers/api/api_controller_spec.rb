require 'rails_helper'

describe API::APIController, type: :controller do
  render_views

  describe '#url_doc' do
    it 'should return an API url based on the first parameter' do
      expect(controller).to receive(:api_potato_url).and_return('http://api.localhost/potato')
      expect(controller.doc_url(:potato)).to eq 'http://api.localhost/potato'
    end

    it 'should pass the second parameter' do
      expect(controller).to receive(:api_potato_url).with("{pot}").and_return('http://api.localhost/potato/{pot}')
      expect(controller.doc_url(:potato,  :pot)).to eq 'http://api.localhost/potato/{pot}'
    end

    it 'should pass any symbol parameter' do
      expect(controller).to receive(:api_potato_url).with("{pot}", "{tup}").and_return('http://api.localhost/potato/{pot}/{tup}')
      expect(controller.doc_url(:potato,  :pot, :tup, 'apple,banana')).to eq 'http://api.localhost/potato/{pot}/{tup}{?apple,banana}'
    end

    it 'should append text parameters' do
      expect(controller).to receive(:api_potato_url).with("{pot}").and_return('http://api.localhost/potato/{pot}')
      expect(controller.doc_url(:potato,  :pot, 'apple,banana')).to eq 'http://api.localhost/potato/{pot}{?apple,banana}'
    end
  end

  describe '#root' do
    it 'should return a list of valid URLs of the API' do
      get :root
      expect(response).to have_http_status :success
      expect(response_json['mods_url']).to           match %r{/mods}
      expect(response_json['mod_url']).to            match %r{/mods/{mod}}
      expect(response_json['categories_url']).to     match %r{/categories}
      expect(response_json['category_url']).to       match %r{/categories/}
      expect(response_json['category_mods_url']).to  match %r{/categories/{category}/mods}
      expect(response_json['authors_url']).to        match %r{/authors}
      expect(response_json['author_url']).to         match %r{/authors/{author}}
      expect(response_json['author_mods_url']).to    match %r{/authors/{author}/mods}
      expect(response_json['user_bookmarks_url']).to match %r{/users/{user}/bookmarks}
    end
  end
end
