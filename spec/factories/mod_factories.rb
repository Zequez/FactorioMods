FactoryGirl.define do
  factory :mod do
    sequence(:name) { |n| "Mod name #{n.to_s.rjust(6, '0')}" }
    categories { build_list :category, 1 }
    description ''
    forum_comments_count 12
    downloads_count 15
    sequence(:info_json_name) { |n| "mod-name-#{n}" }
  end

  factory :category do
    sequence(:name) { |n| "Category #{n}#{n}#{n}" }
  end

  factory :mod_version do
    number '3.5.4'
    released_at 3.weeks.ago
    # game_versions { build_list :game_version, 1 }
    precise_game_versions_string '1.3.5'
    association :mod, factory: :mod
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
