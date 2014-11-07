require 'rails_helper'
include Warden::Test::Helpers

feature 'Modder creates a new mod' do
  scenario 'non-user visits the new mod page' do
    visit '/mods/new'

    expect(page.status_code).to eq 401
  end

  scenario 'user visits new mod page' do
    sign_in
    visit '/mods/new'

    expect(page).to have_content 'Create new mod'
  end

  scenario 'user submits an empty form' do
    sign_in
    visit '/mods/new'
    submit_form
    expect(page).to have_css '#mod_name_input .inline-errors'
    expect(page).to have_css '#mod_category_input .inline-errors'
    expect(current_path).to eq '/mods'
  end

  scenario 'user submits a barebones form' do
    sign_in
    create_category 'Terrain'
    visit '/mods/new'
    fill_in 'Name', with: 'Super Mod'
    select 'Terrain', from: 'Category'
    submit_form
    expect(current_path).to eq '/mods/terrain/super-mod'
    mod = Mod.first
    expect(mod.name).to eq 'Super Mod'
    expect(mod.category).to eq @category
    expect(mod.author).to eq @user
  end

  scenario 'user submits a mod with all the data but no versions' do
    sign_in
    create_category 'Potato category'
    visit '/mods/new'
    fill_in 'Name', with: 'Mah super mod'
    select 'Potato category', from: 'Category'
    fill_in 'Github', with: 'http://github.com/factorio-mods/mah-super-mod'
    fill_in 'Forum URL', with: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5971&sid=1786856d6a687e92f6a12ad9425aeb9e'
    fill_in 'Description', with: 'Lorem ipsum description potato salad simulator'
    fill_in 'Summary', with: 'This is a small mod for testing'
    fill_in 'Media links string', with: "http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman"
    submit_form
    expect(current_path).to eq '/mods/potato-category/mah-super-mod'
    mod = Mod.first
    expect(mod.name).to eq 'Mah super mod'
    expect(mod.category).to eq @category
    expect(mod.github).to eq 'http://github.com/factorio-mods/mah-super-mod'
    expect(mod.forum_url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5971&sid=1786856d6a687e92f6a12ad9425aeb9e'
    expect(mod.description).to eq 'Lorem ipsum description potato salad simulator'
    expect(mod.summary).to eq 'This is a small mod for testing'
    expect(mod.media_links[0].to_string).to eq 'http://imgur.com/gallery/qLpt6gI'
    expect(mod.media_links[1].to_string).to eq 'http://gfycat.com/EthicalZanyHuman'
    expect(mod.author).to eq @user
  end

  scenario 'user submits a mod with invalid media links' do
    sign_in
    category = create :category, name: 'Potato'
    visit '/mods/new'
    fill_in 'Name', with: 'Invalid media link'
    select 'Potato', from: 'Category'
    fill_in 'Media links string', with: "http://imgur.com/gallery/qLpt6gI\nhttp://caca.com\nhttp://gfycat.com/EthicalZanyHuman"
    submit_form
    expect(current_path).to eq '/mods'
    expect(page).to have_content 'Invalid media links'
  end

  # Fuck this. I'm not gonna install a headless Selenium server today.
  # scenario 'user submits mod with a version', js: true do
  #   sign_in
  #   create_category 'Potato'
  #   visit '/mods/new'
  #   fill_in 'Name', with: 'Valid mod name'
  #   click_link 'Add version'
  #   find('.mod-version').fill_in 'Number', with: '123'
  #   # within '.mod-version:nth-child(1)' do
      
  #   # end
  #   submit_form
  #   mod = Mod.first
  #   expect(current_path).to eq '/mods/potato/valid-mod-name'
  #   expect(mod.versions[0].number).to eq '123'
  # end

  def submit_form
    click_button 'Create Mod'
  end

  def sign_in
    @user = create :user
    login_as @user
  end

  def create_category(name)
    @category = create :category, name: name
  end
end