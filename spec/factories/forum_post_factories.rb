# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :forum_post, :class => 'ForumPost' do
    comments_count 5
    views_count 55
    published_at "2014-08-10 19:35:11"
    last_post_at "2014-08-10 19:35:11"
    url "http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5299"
    title { |n| "[0.10.4] Tanks"  }
    author_name 'SkaceKachna'
    post_number { |n| n }
  end
end
