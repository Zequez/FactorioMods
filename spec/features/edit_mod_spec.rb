require 'rails_helper'

include Warden::Test::Helpers

feature 'Modder edits an existing mod' do
  scenario 'submit same basic mod' do
    sign_in
    create_category 'potato'
    mod = create :mod, name: 'Hey', category: @category, author: @user
    visit '/mods/potato/hey/edit'
    submit_form
    expect(current_path).to eq '/mods/potato/hey'
    expect(page).to_not have_content('Edit Hey')
  end


  scenario 'submit same mod with version without file' do
    sign_in
    create_category 'potato'
    mod = create :mod, name: 'Hey', category: @category, author: @user
    create(:mod_version, mod: mod)
    visit '/mods/potato/hey/edit'
    submit_form
    mod = Mod.first
     # Weird bug this one I found.
     # Turns out I wasn't allowing the IDs on the nested mod params, and this was the symptom.
     # Good to remember.
    expect(mod.versions.size).to eq 1
    expect(current_path).to eq '/mods/potato/hey'
    expect(page).to_not have_content('Edit Hey')
  end

  def submit_form
    click_button 'Update Mod'
  end

  def create_category(name)
    @category = create :category, name: name
  end
end