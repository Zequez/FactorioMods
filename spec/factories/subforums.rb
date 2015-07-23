FactoryGirl.define do
  factory :subforum do
    sequence(:url) { |n| "http://www.factorioforums.com/forum/viewforum.php?f=#{n}" }
    sequence(:name) { |n| "Subforum #{n}" }
    game_version nil
    scrap true
    sequence(:number) { |n| n }
  end
end
