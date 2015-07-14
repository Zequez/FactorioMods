require 'rails_helper'
include Warden::Test::Helpers

feature 'Modder creates a new mod' do
  scenario 'non-user visits the new mod page' do
    visit '/mods/new'

    expect(page.status_code).to eq 401
  end

  scenario 'user visits new mod page' do
    sign_in_dev
    visit '/mods/new'

    expect(page).to have_content 'Create new mod'
  end

  # scenario 'user submits an empty form' do
  #   sign_in
  #   visit '/mods/new'
  #   submit_form
  #   expect(page).to have_css '#mod_name_input .inline-errors'
  #   expect(page).to have_css '#mod_category_input .inline-errors'
  #   expect(current_path).to eq '/mods'
  # end

  scenario 'user submits a barebones form' do
    sign_in_dev
    create_category 'Terrain'
    visit '/mods/new'
    fill_in 'mod_name', with: 'Super Mod'
    select 'Terrain', from: 'Categories'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods/super-mod'
    mod = Mod.first
    expect(mod.name).to eq 'Super Mod'
    expect(mod.categories).to match_array [@category]
    expect(mod.author).to eq @user
  end

  scenario 'user submits a mod with all the data but no versions' do
    sign_in_dev
    create_category 'Potato category'
    visit '/mods/new'
    fill_in 'mod_name', with: 'Mah super mod'
    select 'Potato category', from: 'Categories'
    fill_in 'Github', with: 'http://github.com/factorio-mods/mah-super-mod'
    fill_in 'Forum post URL', with: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5971&sid=1786856d6a687e92f6a12ad9425aeb9e'
    fill_in 'Official URL', with: 'http://www.factorioforums.com/'
    fill_in 'Summary', with: 'This is a small mod for testing'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods/mah-super-mod'
    mod = Mod.first
    expect(mod.name).to eq 'Mah super mod'
    expect(mod.categories).to match_array [@category]
    expect(mod.github).to eq 'factorio-mods/mah-super-mod'
    expect(mod.forum_url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5971&sid=1786856d6a687e92f6a12ad9425aeb9e'
    expect(mod.official_url).to eq 'http://www.factorioforums.com/'
    expect(mod.summary).to eq 'This is a small mod for testing'
    expect(mod.author).to eq @user
  end


  scenario 'user submits mod with a version and file' do
    sign_in_dev
    create_category 'Potato'
    create :game_version, number: '1.1.x'
    create :game_version, number: '1.2.x'
    attachment = File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
    visit '/mods/new'
    fill_in 'mod_name', with: 'Valid mod name'
    select 'Potato', from: 'Categories'
    within('.mod-version:nth-child(1)') do
      fill_in 'Number', with: '123'
      fill_in 'Release day', with: '2014-11-09'  
      select '1.1.x', from: 'Game versions'
      select '1.2.x', from: 'Game versions'
      click_link 'Add file'
      within('.mod-version-file:nth-child(1)') do
        attach_file 'Attachment', attachment.path
      end
    end
    submit_form
    mod = Mod.first
    expect(current_path).to eq '/mods/valid-mod-name'
    expect(page).to have_content 'Valid mod name'
    expect(mod.versions[0].number).to eq '123'
    expect(mod.versions[0].released_at).to eq Time.zone.parse('2014-11-09')
    expect(mod.versions[0].game_versions[0].number).to eq '1.1.x'
    expect(mod.versions[0].game_versions[1].number).to eq '1.2.x'
    expect(mod.versions[0].files[0].attachment_file_size).to eq attachment.size
  end

  scenario 'admin user submits a mod selecting an author' do
    sign_in_admin
    create_category 'Potato'
    visit '/mods/new'
    fill_in 'mod_name', with: 'Mod Name'
    select 'Potato', from: 'Categories'
    fill_in 'Author name', with: 'MangoDev'
    fill_in_first_version_and_file
    submit_form
    mod = Mod.first
    expect(current_path).to eq '/mods/mod-name'
    expect(mod.author_name).to eq 'MangoDev'
  end

  scenario 'admin tries to create a mod from the forum_posts dashboard, so it has pre-filled attributes' do
    sign_in_admin
    create_category 'Potato'
    released_at = 5.days.ago
    forum_post = create :forum_post, title: '[0.11.x] Potato mod',
                                     author_name: 'SuperGuy', 
                                     published_at: released_at, 
                                     url: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=6742'

    # We mock the forum post page here
    mocked_page = File.read File.expand_path("../../fixtures/forum_post/basic_post.html", __FILE__)
    stub_request(:get, forum_post.url).to_return body: mocked_page

    visit "/mods/new?forum_post_id=#{forum_post.id}"
    expect(find('#mod_name').value).to eq '[0.11.x] Potato mod'
    expect(find('#mod_author_name').value).to eq 'SuperGuy'
    expect(find('#mod_forum_url').value).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=6742'
    expect(find('[id$=released_at]').value).to eq released_at.strftime('%Y-%m-%d')
  end

  scenario 'tries to submit mod with the same name as an existing mod, it works fine' do
    sign_in_dev
    @user.name = 'yeah'
    @user.save!
    create_category 'Potato'
    mod = create :mod, name: 'SuperMod', categories: [@category]

    visit "/mods/new"
    fill_in 'mod_name', with: 'SuperMod'
    select 'Potato', from: 'Categories'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods/supermod-yeah'
  end

  def fill_in_first_version_and_file
    attachment = File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
    within('.mod-version:nth-child(1)') do
      fill_in 'Number', with: '123'
      within('.mod-version-file:nth-child(1)') do
        attach_file 'Attachment', attachment.path
      end
    end
  end

  def submit_form
    click_button 'Create Mod'
  end

  def create_category(name)
    @category = create :category, name: name
  end
end