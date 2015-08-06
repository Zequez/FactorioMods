describe Users::RegistrationsController, type: :controller do
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST create' do
    it 'should create a new user with valid parameters' do
      post :create, user: {
        email: 'potato@salad.com',
        name: 'Potato',
        password: '12345678',
      }
      user = User.first
      expect(user.email).to eq 'potato@salad.com'
      expect(user.name).to eq 'Potato'
      expect(response).to redirect_to root_path
    end

    it 'should add errors to the user with invalid parameters' do
      post :create, user: {
        email: 'potatosalad.com',
        name: '',
        password: '1278'
      }
      expect(User.all).to be_empty
      user = assigns(:user)
      expect(user.errors[:email]).to_not be_empty
      expect(user.errors[:forum_name]).to be_empty
      expect(user.errors[:password]).to_not be_empty
      expect(response).to render_template :new
    end

    context 'the user used a name associated with an author' do
      it 'should redirect to forum_validations#new after creating the user' do
        create :author, name: 'Potato', forum_name: 'Potato'

        post :create, user: {
          email: 'potato@salad.com',
          name: 'Potato',
          password: '12345678'
        }

        expect(response).to redirect_to new_forum_validation_path
      end
    end

    context 'the user used a forum_name not associated with any author' do
      it 'should redirect to the root as usual' do
        create :author, name: 'Potato', forum_name: 'Potato'

        post :create, user: {
          email: 'potato@salad.com',
          name: 'rsarsarsa',
          password: '12345678'
        }

        expect(response).to redirect_to root_path
      end
    end
  end
end
