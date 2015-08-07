include Warden::Test::Helpers

feature 'The goddamn game version string should be updated after editing a mod' do
  scenario 'You submit a new mod with a mod version that
  depends on certain Factorio versions, then you go to mods#show and the version
  string is the correct one, but then you mods#edit the mod and you reduce the Factorio
  versions of the mod_version that is compatible with, then you look at mods#show again and
  the string should be updated' do
    create :category, name: 'CategoryOne'
    gv1 = create :game_version, number: '0.10', sort_order: 1
    gv2 = create :game_version, number: '0.11', sort_order: 2
    sign_in_admin
    visit '/mods/new'
    fill_in 'mod_name', with: 'This Bug, Man'
    fill_in 'mod_info_json_name', with: 'this-bug'
    select 'CategoryOne', from: 'mod_category_ids'
    fill_in 'mod_author_name', with: 'Whatever'
    fill_in 'mod_versions_attributes_0_number', with: '1.2.3'
    fill_in 'mod_versions_attributes_0_released_at', with: '2015-01-01'
    select '0.10', from: 'mod_versions_attributes_0_game_version_ids'
    select '0.11', from: 'mod_versions_attributes_0_game_version_ids'
    fill_in 'mod_versions_attributes_0_files_attributes_0_download_url', with: 'http://potato.com'
    find('#mod_submit_action input').click()
    expect(current_path).to eq '/mods/this-bug-man'
    expect(page).to have_content '0.10-0.11'
    click_link 'Edit mod'
    unselect '0.10', from: 'mod_versions_attributes_0_game_version_ids'
    find('#mod_submit_action input').click()
    expect(ModGameVersion.all.size).to eq 1
    expect(Mod.first.versions.first.game_versions).to match_array [gv2]
    expect(Mod.first.game_versions_string).to eq '0.11'
    # And check that using dependant: :destroy with has_many through
    # doesn't actually destroys the game version
    expect(GameVersion.all).to match_array [gv1, gv2]
  end
end
