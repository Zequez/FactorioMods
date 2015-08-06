describe ForumValidationsController, type: :controller do
  describe 'POST create' do
    it 'should create a new ForumValidation with the current user and given author' do
      user = create :user
      author = create :author
      sign_in user
      expect_any_instance_of(ForumValidation).to receive(:send_pm).and_return true
      post :create, forum_validation: { author_id: author.id }
      fv = ForumValidation.first
      expect(fv.user).to eq user
      expect(fv.author).to eq author
      expect(fv.validated).to eq false
      expect(fv.vid.size).to eq 50
      expect(response).to redirect_to fv
    end

    it 'should throw a server error with invalid parameters' do
      user = create :user
      sign_in user
      post :create, forum_validation: { user_id: user.id, author_id: 4321 }
      expect(response).to have_http_status :bad_request
    end

    it 'should redirect with an error flash message if the validation fails' do
      user = create :user
      author = create :author
      sign_in user
      expect_any_instance_of(ForumValidation).to receive(:send_pm).and_return false
      post :create, forum_validation: { author_id: author.id }
      fv = ForumValidation.first
      expect(flash[:error]).to eq I18n.t('forum_validations.flash.create.pm_error')
      expect(response).to redirect_to fv
    end

    it 'should be unauthorized while not logged in' do
      author = create :author
      post :create, forum_validation: { author_id: author.id }
      expect(response).to have_http_status :unauthorized
    end

    it 'should redirect to the existing validation if the user already has one' do
      user = create :user
      author = create :author
      sign_in user
      fv = create :forum_validation, user: user, author: author
      expect_any_instance_of(ForumValidation).to_not receive(:send_pm)
      post :create, forum_validation: { author_id: author.id }
      expect(response).to redirect_to fv
    end
  end

  # Yes, GET
  describe 'GET update' do
    before(:each) do
      @user = create :user
      @author = create :author
      create :mod, authors: [@author], owner: nil
      create :mod, authors: [@author], owner: nil
      @fv = create :forum_validation, user: @user, author: @author
    end

    context 'with the correct #vid' do
      before(:each) do
        get :update, id: @fv.id, vid: @fv.vid
        @fv.reload
        @user.reload
        @author.reload
      end

      it 'should set the fv to validated' do
        expect(@fv.validated).to eq true
      end

      it 'should associate the user and author' do
        expect(@user.author).to eq @author
        expect(@author.user).to eq @user
      end

      it 'should redirect to the fv' do
        expect(response).to redirect_to @fv
      end

      it 'should set the corresponding flash message' do
        expect(flash[:notice]).to eq I18n.t('forum_validations.flash.update.success')
      end

      it 'should set the ownership of all the mods associated with the author to the user' do
        expect(@author.mods[0].owner).to eq @user
        expect(@author.mods[1].owner).to eq @user
      end
    end

    describe 'with the incorrect #vid' do
      before(:each) do
        get :update, id: @fv.id, vid: 'rsniahsraeitn'
        @fv.reload
        @user.reload
        @author.reload
      end

      it 'should still be #validated false' do
        expect(@fv.validated).to eq false
      end

      it 'should NOT associate the user and author' do
        expect(@user.author).to eq nil
        expect(@author.user).to eq nil
      end

      it 'throw a server error' do
        expect(response).to have_http_status :bad_request
      end

      it 'should not set ownership of the mods associated with the author to the user' do
        expect(@author.mods[0].owner).to eq nil
        expect(@author.mods[1].owner).to eq nil
      end
    end

    describe 'with an already validated ForumValidation' do
      before(:each) do
        @fv.associate_user_and_author!
        @fv.user.give_ownership_of_authored!
        get :update, id: @fv.id, vid: @fv.vid
        @fv.reload
        @user.reload
        @author.reload
      end

      it 'should redirect the user to the fv' do
        expect(response).to redirect_to @fv
      end

      it 'should set a different flash message' do
        expect(flash[:notice]).to eq I18n.t('forum_validations.flash.update.already_success')
      end
    end
  end

  describe 'GET show' do
    it 'should render the show template' do
      @fv = create :forum_validation
      @m1 = create :mod, authors: [@fv.author]
      @m2 = create :mod, authors: [@fv.author]
      @fv.associate_user_and_author!
      @fv.user.give_ownership_of_authored!
      sign_in @fv.user
      get :show, id: @fv.id
      expect(response).to have_http_status :success
      expect(response).to render_template :show
    end
  end

  describe 'GET new' do
    context 'logged in user' do
      it 'should just render the new form if it can be validated' do
        author = create :author, forum_name: 'Potato', name: 'Potato'
        sign_in create(:user, forum_name: 'Potato')
        get :new
        expect(assigns(:forum_validation).author).to eq author
        expect(response).to render_template :new
      end

      it 'should redirect to the root if the user is already validated' do
        author = create :author, forum_name: 'Potato', name: 'Potato'
        user = create :user, forum_name: 'Potato'
        create :forum_validation, author: author, user: user, validated: true
        sign_in user
        get :new
        expect(response).to redirect_to root_path
      end

      it 'should redirect to the forum_validations#show if the user has a pending validation' do
        author = create :author, forum_name: 'Potato', name: 'Potato'
        user = create :user, forum_name: 'Potato'
        fv = create :forum_validation, author: author, user: user, validated: false
        sign_in user
        get :new
        expect(response).to redirect_to fv
      end
    end

    context 'logged out user' do
      it 'should redirect to login form' do
        create :author, forum_name: 'Potato', name: 'Potato'
        create :user, forum_name: 'Potato'
        get :new
        expect(response).to have_http_status :redirect
        expect(response.location).to match new_user_session_path
      end
    end
  end
end
