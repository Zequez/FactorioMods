FactoryGirl.define do
  factory :bookmark do
    association :mod, factory: :mod
    association :user, factory: :user
  end
end
