FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "Potatohead #{n}" }
    sequence(:email) {|n| "potatohead#{n}@gmail.com" }
    password 'rsarsarsa'
  end

  factory :developer, class: 'User' do
    name 'Foo Barinto'
  end
end
