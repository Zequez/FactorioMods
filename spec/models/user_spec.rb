require 'rails_helper'

RSpec.describe User, :type => :model do
    it { should respond_to :name }
    it { should respond_to :email }
    it { should respond_to :is_dev? }
    it { should respond_to :is_admin? }
    it { should respond_to :slug }

    describe 'validations' do
      it 'should not allow user without name' do
        user = build :user, name: ''
        expect(user).to be_invalid
      end

      it 'should not allow user without email' do
        user = build :user, email: ''
        expect(user).to be_invalid
      end

      it 'should not allow user without password' do
        user = build :user, password: ''
        expect(user).to be_invalid
      end

      it 'should not allow user with missmatching password confirmation' do
        user = build :user, password: 'rsarsarsarsa', password_confirmation: 'asrasrasrasr'
        expect(user).to be_invalid
      end

      it 'should not allow spaces in the name' do
        user = build :user, name: 'Potato Head'
        expect(user).to be_invalid
      end

      it 'should not allow users with the same name' do
        user1 = create :user, name: 'HeyHeyNanana'
        user2 = build :user, name: 'HeyHeyNanana'
        expect(user2).to be_invalid
      end

      it 'should not allow users with the same name with different cases' do
        user1 = create :user, name: 'HeyHeyNanana'
        user2 = build :user, name: 'heyheynanana'
        expect(user2).to be_invalid
      end
    end

    describe 'attributes' do
      it 'should generate a slug with the name' do
        user = create :user, name: 'PotatoHead'
        expect(user.slug).to eq 'potatohead'
      end
    end
end
