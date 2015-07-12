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
    expect(page).to have_css 'img[src="http://i.imgur.com/qLpt6gI.jpg"]'
  end

  scenario 'Visiting the mod page as the owner of the mod should display a link to edit the mod' do
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category]
    visit '/mods/super-mod'
    expect(page).to have_link 'Edit mod', '/mods/super-mod/edit'
  end
end