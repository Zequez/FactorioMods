
describe Users::SessionsController, type: :controller do
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST create' do
    before :each do
      @user = create :user,
        email: 'potato@salad.com',
        name: 'Potato',
        password: 'yeahyeah'
    end

    it 'should allow you to sign in with an email on #login' do
      post :create, user: {
        login: 'potato@salad.com',
        password: 'yeahyeah'
      }
      expect(controller.current_user).to eq @user
      expect(response).to have_http_status :redirect
    end

    it 'should allow you to sign in with a name on #login' do
      post :create, user: {
        login: 'Potato',
        password: 'yeahyeah'
      }
      expect(controller.current_user).to eq @user
      expect(response).to have_http_status :redirect
    end

    it "should assign a user with an error to :base if the name or email doesn't exist" do
      post :create, user: {
        login: 'rsarsarsa',
        password: 'yeahyeah'
      }
      expect(controller.current_user).to eq nil
      expect(response).to have_http_status :ok
      expect(response).to render_template 'new'
    end
  end
end
