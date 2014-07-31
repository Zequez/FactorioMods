# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game_versions_mod, :class => 'GameVersionsMods' do
    game_version nil
    mods nil
  end
end
