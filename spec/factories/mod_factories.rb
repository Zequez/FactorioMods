FactoryGirl.define do
  factory :mod do
    sequence(:name) { |n| "Mod name #{n}" }
    association :author, factory: :user
    categories { build_list :category, 1 }
    description ''
    forum_comments_count 12
    downloads_count 15
  end

  factory :category do
    sequence(:name) { |n| "Category #{n}#{n}#{n}" }
  end

  factory :mod_asset do
    image { File.new(Rails.root.join('spec', 'fixtures', 'test.jpg')) }
  end

  factory :mod_video_asset, class: 'ModAsset' do
    video_url 'http://www.youtube.com/watch?v=C0DPdy98e4c'
  end

  factory :mod_version do
    number '3.5.4'
    released_at 3.weeks.ago
    # game_versions { build_list :game_version, 1 }
    precise_game_versions_string '1.3.5'
  end

  factory :game_version do
    number '0.10.2'
     sequence(:sort_order) { |n| n.to_i }
  end

  factory :game_version_end do
    number '0.11.4'
    sequence(:sort_order) { |n| n.to_i }
  end

  factory :mod_file do
    sequence(:name) { |n| "Mod File Name #{n}#{n}" }
    attachment { File.new(Rails.root.join('spec', 'fixtures', 'test.zip')) }
    mod_version
  end

  factory :game do
    sequence(:name) { |n| "GameName #{n}#{n}" }
  end
end