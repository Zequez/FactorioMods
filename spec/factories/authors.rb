FactoryGirl.define do
  factory :author do
    sequence(:name) { |n| "AuthorName#{n.to_s.rjust(6, '0')}" }
    sequence(:github_name) { |n| "AuthorGithubName#{n.to_s.rjust(6, '0')}" }
    sequence(:forum_name) { |n| "AuthorForumName#{n.to_s.rjust(6, '0')}" }
    user nil
  end
end
