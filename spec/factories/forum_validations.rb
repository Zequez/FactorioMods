FactoryGirl.define do
  factory :forum_validation do
    association :user, factory: :user
    association :author, factory: :author
    validated false
  end
end
