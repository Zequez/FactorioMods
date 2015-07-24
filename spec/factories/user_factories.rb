FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "Potatohead#{n}" }
    sequence(:email) {|n| "potatohead#{n}@gmail.com" }
    password 'rsarsarsa'
    
    factory :dev_user do
      is_dev true
    end
    
    factory :admin_user do
      is_admin true
    end
  end

  factory :developer, class: 'User' do
    name 'Foo Barinto'
  end
end
