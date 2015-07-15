require 'rails_helper'
include Warden::Test::Helpers

feature 'Display full mod information' do
  scenario 'Mod with just name and category' do
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category]
    visit '/mods/super-mod'
    expect(page).to have_content 'Super Mod'
    expect(page).to have_content 'Potato category'
  end

  scenario 'Mod with name, category and media links' do
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category], imgur: "qLpt6gI"
    visit '/mods/super-mod'
    expect(page).to have_content 'Super Mod'
    expect(page).to have_content 'Potato category'
    expect(page).to have_css 'img[src="http://i.imgur.com/qLpt6gIl.jpg"]'
  end

  scenario 'Visiting the mod page as the owner of the mod should display a link to edit the mod' do
    sign_in
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category], author: @user
    visit '/mods/super-mod'
    expect(page).to have_link 'Edit mod', '/mods/super-mod/edit'
  end

  scenario 'Visiting the mod page as a guest should not display a link to edit the mod' do
    sign_in
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category], author: build(:user)
    visit '/mods/super-mod'
    expect(page).to_not have_link 'Edit mod', '/mods/super-mod/edit'
  end

  scenario 'Visiting the mod page as an admin display a link to edit the mod regardless of the owner' do
    sign_in
    @user.is_admin = true
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category], author: build(:user)
    visit '/mods/super-mod'
    expect(page).to have_link 'Edit mod', '/mods/super-mod/edit'
  end

  scenario 'Mod with multiple releases should sort them by newer to older' do
    mod = create :mod, name: 'SuperMod'
    mv1 = build :mod_version, released_at: 1.year.ago, number: 'aaaaa', files: [build(:mod_file)]
    mv2 = build :mod_version, released_at: 1.month.ago, number: 'bbbbb', files: [build(:mod_file)]
    mv3 = build :mod_version, released_at: 2.years.ago, number: 'ccccc', files: [build(:mod_file)]
    mod.versions = [mv1, mv2, mv3]
    mod.save!
    visit '/mods/supermod'
    expect(page.find('.mod-downloads-table')).to have_content /bbbbb.*aaaaa.*ccccc/
  end
end