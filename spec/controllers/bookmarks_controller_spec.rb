describe BookmarksController, type: :controller do
  describe 'GET index' do
    it 'should assign the user bookmarked mods when visiting it' do
      user = create :user
      mod = create :mod
      create :bookmark, user: user, mod: mod
      sign_in user
      get :index
      expect(response).to have_http_status :ok
      expect(assigns(:mods)).to eq [mod]
    end

    it 'should redirect to login for non registered users' do
      get :index
      expect(response).to have_http_status :redirect
    end
  end

  describe 'POST create' do
    it 'should be :unauthorized for non registered users' do
      mod = create :mod
      post :create, bookmark: { mod_id: mod.id }
      expect(response).to have_http_status :unauthorized
    end

    it 'should create a new bookmark for the given mod and the current user' do
      user = create :user
      mod = create :mod
      sign_in user

      post :create, bookmark: { mod_id: mod.id }
      expect(response).to have_http_status :ok
      user.reload
      expect(user.bookmarked_mods).to eq [mod]
    end

    it 'should be :bad_request if the mod already has a bookmark' do
      user = create :user
      mod = create :mod
      create :bookmark, user: user, mod: mod
      sign_in user

      post :create, bookmark: { mod_id: mod.id }
      expect(response).to have_http_status :bad_request
      user.reload
      expect(user.bookmarked_mods).to eq [mod]
    end

    it 'should be :bad_request for a non-existant mod' do
      user = create :user
      sign_in user

      post :create, bookmark: { mod_id: 1293723 }
      expect(response).to have_http_status :bad_request
    end
  end

  describe 'DELETE destroy' do
    it 'should delete the bookmark associated with the user and mod' do
      user = create :user
      mod = create :mod
      create :bookmark, user: user, mod: mod
      sign_in user

      delete :destroy, bookmark: { mod_id: mod.id }
      expect(response).to have_http_status :ok
      user.reload
      expect(user.bookmarked_mods).to eq []
    end

    it 'should be :not_found to delete a non-existant bookmark' do
      user = create :user
      mod = create :mod
      sign_in user

      delete :destroy, bookmark: { mod_id: mod.id }
      expect(response).to have_http_status :not_found
    end
  end
end
