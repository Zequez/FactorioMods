# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mod_game_version, :class => 'ModGameVersion' do
    game_version nil
    mod_version nil
    mod nil
  end
end