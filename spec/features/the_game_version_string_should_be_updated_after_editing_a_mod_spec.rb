require 'rails_helper'
include Warden::Test::Helpers

feature 'The goddamn game version string should be updated after editing a mod' do
  scenario 'You submit a new mod with a mod version that
  depends on certain Factorio versions, then you go to mods#show and the version
  string is the correct one, but then you mods#edit the mod and you reduce the Factorio
  versions of the mod_version that is compatible with, then you look at mods#show again and
  the string should be updated' do
    cat1 = create :category, name: 'CategoryOne'
    gv1 = create :game_version, number: '0.10', sort_order: 1
    gv2 = create :game_version, number: '0.11', sort_order: 2
    sign_in_admin
    visit '/mods/new'
    nfind('mod[name]').set 'This Bug, Man'
    nfind(:select, 'mod[category_ids][]').select 'CategoryOne'
    nfind('mod[author_name]').set 'Whatever'
    nfind('mod[versions_attributes][0][number]').set '1.2.3'
    nfind('mod[versions_attributes][0][released_at]').set '2015-01-01'
    nfind(:select, 'mod[versions_attributes][0][game_version_ids][]').select '0.10'
    nfind(:select, 'mod[versions_attributes][0][game_version_ids][]').select '0.11'
    nfind('mod[versions_attributes][0][files_attributes][0][download_url]').set 'http://potato.com'
    nfind('commit').click()
    expect(current_path).to eq '/mods/this-bug-man'
    expect(page).to have_content '0.10-0.11'
    click_link 'Edit mod'
    nfind(:select, 'mod[versions_attributes][0][game_version_ids][]').unselect '0.10'
    nfind('commit').click()
    expect(ModGameVersion.all.size).to eq 1
    expect(Mod.first.versions.first.game_versions).to match_array [gv2]
    expect(Mod.first.game_versions_string).to eq '0.11'
    # And check that using dependant: :destroy with has_many through
    # doesn't actually destroys the game version
    expect(GameVersion.all).to match_array [gv1, gv2]
  end
end