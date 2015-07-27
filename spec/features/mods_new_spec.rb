require 'rails_helper'
include Warden::Test::Helpers

feature 'Modder creates a new mod' do
  before :each do
    create_category 'Terrain'
  end

  describe 'authentication' do
    scenario 'non-user visits the new mod page' do
      visit '/mods/new'

      expect(page.status_code).to eq 401
    end
    
    
    scenario 'non-dev user visits the new mod page' do
      sign_in
      visit '/mods/new'

      expect(page.status_code).to eq 200
      expect(page).to have_content 'Create new mod'
    end

    scenario 'dev user visits new mod page' do
      sign_in_dev
      visit '/mods/new'
      
      expect(page.status_code).to eq 200
      expect(page).to have_content 'Create new mod'
    end
    
    
    scenario 'admin user visits new mod page' do
      sign_in_admin
      visit '/mods/new'
      
      expect(page.status_code).to eq 200
      expect(page).to have_content 'Create new mod'
    end
  end

  describe 'minimum values' do
    scenario 'user submits an empty form' do
      sign_in_dev
      visit '/mods/new'
      submit_form
      expect(page).to have_css '#mod_name_input .inline-errors'
      expect(page).to have_css '#mod_categories_input .inline-errors'
      expect(current_path).to eq '/mods'
    end

    scenario 'user submits a barebones form' do
      sign_in_dev
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

    scenario 'user submits a form without any mod version', js: true do
      sign_in_dev
      visit '/mods/new'
      fill_in 'mod_name', with: 'Super Mod'
      select 'Terrain', from: 'Categories'
      first('.remove_fields').click
      submit_form
      expect(current_path).to eq '/mods/super-mod'
      mod = Mod.first
      expect(mod.name).to eq 'Super Mod'
      expect(mod.categories).to match_array [@category]
      expect(mod.author).to eq @user
    end
  end

  describe 'categories validations' do
    scenario 'user submits a mod with more than 8 categories' do
      9.times{ |i| create_category "Cat#{i}" }
      sign_in_dev
      visit '/mods/new'
      fill_in 'mod_name', with: 'ModName'
      9.times{ |i| select "Cat#{i}", from: 'Categories' }
      fill_in_first_version_and_file
      submit_form
      expect(current_path).to eq '/mods'
      expect(page).to have_css '#mod_categories_input .inline-errors'
    end

    scenario 'user submits a mod with less than 8 categories' do
      9.times{ |i| create_category "Cat#{i}" }
      sign_in_dev
      visit '/mods/new'
      fill_in 'mod_name', with: 'ModName'
      7.times{ |i| select "Cat#{i}", from: 'Categories' }
      fill_in_first_version_and_file
      submit_form
      expect(current_path).to eq '/mods/modname'
    end
  end

  describe 'mod_version validation' do
    scenario 'user submits a mod with a mod_version with strange characters' do
      sign_in_dev
      visit '/mods/new'
      fill_in 'mod_name', with: 'ModName'
      select 'Terrain', from: 'Categories'
      within('.mod-version:nth-child(1)') do
        fill_in 'Number', with: '123 324$#OE'
        fill_in 'Release day', with: 3.weeks.ago
        within('.mod-version-file:nth-child(1)') do
          fill_in 'Release download URL', with: 'http://github.com/release/something.zip'
        end
      end
      submit_form
      expect(current_path).to eq '/mods'
      expect(page).to have_css '#mod_versions_attributes_0_number_input .inline-errors'
    end

    scenario 'user submits a mod with a mod_version with a perfectly fine number' do
      sign_in_dev
      visit '/mods/new'
      fill_in 'mod_name', with: 'ModName'
      select 'Terrain', from: 'Categories'
      within('.mod-version:nth-child(1)') do
        fill_in 'Number', with: '1.2.3_5-potato'
        fill_in 'Release day', with: 3.weeks.ago
        within('.mod-version-file:nth-child(1)') do
          fill_in 'Release download URL', with: 'http://github.com/release/something.zip'
        end
      end
      submit_form
      expect(current_path).to eq '/mods/modname'
    end
  end

  scenario 'user submits a mod with all the data but no versions' do
    sign_in_dev
    visit '/mods/new'
    fill_in 'mod_name', with: 'Mah super mod'
    select 'Terrain', from: 'Categories'
    fill_in 'Github', with: 'http://github.com/factorio-mods/mah-super-mod'
    fill_in 'Forum post URL', with: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5971&sid=1786856d6a687e92f6a12ad9425aeb9e'
    fill_in 'Official URL', with: 'http://www.factorioforums.com/'
    fill_in 'Summary', with: 'This is a small mod for testing'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods/mah-super-mod'
    mod = Mod.first
    expect(mod.name).to eq 'Mah super mod'
    expect(mod.categories).to match_array [Category.first]
    expect(mod.github).to eq 'factorio-mods/mah-super-mod'
    expect(mod.forum_url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5971&sid=1786856d6a687e92f6a12ad9425aeb9e'
    expect(mod.official_url).to eq 'http://www.factorioforums.com/'
    expect(mod.summary).to eq 'This is a small mod for testing'
    expect(mod.author).to eq @user
  end


  scenario 'user submits mod with a version and file' do
    sign_in_dev
    create :game_version, number: '1.1.x'
    create :game_version, number: '1.2.x'
    attachment = File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
    visit '/mods/new'
    fill_in 'mod_name', with: 'Valid mod name'
    select 'Terrain', from: 'Categories'
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

  scenario 'admin user submits a mod selecting an owner' do
    sign_in_admin
    visit '/mods/new'
    fill_in 'mod_name', with: 'Mod Name'
    select 'Terrain', from: 'Categories'
    fill_in 'mod_authors_list', with: 'MangoDev'
    fill_in_first_version_and_file
    submit_form
    mod = Mod.first
    expect(current_path).to eq '/mods/mod-name'
    expect(mod.authors.first.name).to eq 'MangoDev'
  end

  scenario 'admin tries to create a mod from the forum_posts dashboard, so it has pre-filled attributes' do
    sign_in_admin
    released_at = 5.days.ago
    game_version = create :game_version
    subforum = create :subforum, game_version: game_version
    forum_post = create :forum_post, title: '[0.11.x] Potato mod',
                                     author_name: 'SuperGuy',
                                     published_at: released_at,
                                     subforum: subforum,
                                     url: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=6742'

    visit "/mods/new?forum_post_id=#{forum_post.id}"
    expect(find('#mod_name').value).to eq '[0.11.x] Potato mod'
    expect(find('#mod_authors_list').value).to eq 'SuperGuy'
    expect(find('#mod_forum_url').value).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=6742'
    expect(find('[id$=game_version_ids]').value).to eq [game_version.id.to_s]
    expect(find('[id$=released_at]').value).to eq released_at.strftime('%Y-%m-%d')
  end

  scenario 'tries to submit mod with the same name as an existing mod, it works fine' do
    sign_in_dev
    @user.name = 'yeah'
    @user.save!
    mod = create :mod, name: 'SuperMod'

    visit "/mods/new"
    fill_in 'mod_name', with: 'SuperMod'
    select 'Terrain', from: 'Categories'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods/supermod-by-yeah'
  end

  scenario 'user submits a mod with valid names in the #authors_list' do
    sign_in_dev
    visit '/mods/new'
    fill_in 'mod_name', with: 'SuperMod'
    select 'Terrain', from: 'Categories'
    fill_in 'mod_authors_list', with: 'Potato, SuperUser, Salad'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods/supermod'
    expect(Mod.first.authors.map(&:name)).to eq %w{Potato SuperUser Salad}
  end

  scenario 'user submits a mod with invalid names in the #authors_list' do
    sign_in_dev
    visit '/mods/new'
    fill_in 'mod_name', with: 'SuperMod'
    select 'Terrain', from: 'Categories'
    fill_in 'mod_authors_list', with: 'Potato(), SuperUser, Salad'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods'
    expect(page).to have_css '#mod_authors_list_input .inline-errors'
    expect(page).to have_content /Potato\(\) is invalid/
  end

  scenario 'user submits a mod too many authors in the #authors_list' do
    sign_in_dev
    visit '/mods/new'
    fill_in 'mod_name', with: 'SuperMod'
    select 'Terrain', from: 'Categories'
    fill_in 'mod_authors_list', with: 'Potato, SuperUser, Salad, Tururu, Papapa, Aaaaa, Bbbbb, Ccccc, Ddddd'
    fill_in_first_version_and_file
    submit_form
    expect(current_path).to eq '/mods'
    expect(page).to have_css '#mod_authors_list_input .inline-errors'
    expect(page).to have_content /too many/i
  end
  
  describe 'visibility toggle' do
    scenario 'should be hidden for non-dev, and false' do
      sign_in
      visit '/mods/new'
      expect(page).to_not have_css '#mod_visible'
      fill_in_minimum
      submit_form
      expect(Mod.first.visible).to eq false
    end
    
    shared_examples 'admin or dev' do
      scenario 'should be visible and ON by default' do
        sign_in_admin_or_dev
        visit '/mods/new'
        expect(page).to have_css '#mod_visible'
        expect(find('#mod_visible').value).to eq '1'
        fill_in_minimum
        submit_form
        expect(Mod.first.visible).to eq true
      end
      
      scenario 'should be visible it should be changeable' do
        sign_in_admin_or_dev
        visit '/mods/new'
        expect(page).to have_css '#mod_visible'
        expect(find('#mod_visible').value).to eq '1'
        uncheck 'mod_visible'
        fill_in_minimum
        submit_form
        expect(Mod.first.visible).to eq false
      end
    end
    
    context 'dev user' do
      it_behaves_like 'admin or dev' do
        let(:sign_in_admin_or_dev){ sign_in_dev }
      end
    end
    
    context 'admin user' do
      it_behaves_like 'admin or dev' do
        let(:sign_in_admin_or_dev){ sign_in_admin }
      end
    end
    
    # context 'dev or admin submits a mod' do
    #   scenario 'should be visible and ON by default' do
    #     sign_in_dev
    #     visit '/mods/new'
    #     expect(page).to have_css '#mod_visible_input'
    #     expect(find('#mod_visible_input').value).to eq true
    #     fill_in_minimum
    #     submit_form
    #     expect(Mod.first.visible).to eq true
    #   end
      
    #   scenario 'should be visible it should be changeable' do
    #     sign_in_dev
    #     visit '/mods/new'
    #     expect(page).to have_css '#mod_visible_input'
    #     expect(find('#mod_visible_input').value).to eq true
    #     uncheck 'mod_visible_input'
    #     fill_in_minimum
    #     submit_form
    #     expect(Mod.first.visible).to eq false
    #   end
    # end
    
    
    # scenario 'should be visible if an admin visits mods#new, and it should be ON by default' do
    #   sign_in
    #   visit '/mods/new'
    #   expect(page).to have_css '#mod_visible_input'
    #   expect(find('#mod_visible_input').value).to eq true
    #   fill_in_minimum
    #   submit_form
    #   expect(Mod.first.visible).to eq true
    # end
  end
  
  def fill_in_minimum
    fill_in 'mod_name', with: 'SuperMod'
    select 'Terrain', from: 'Categories'
    fill_in_first_version_and_file
  end

  def fill_in_first_version_and_file
    attachment = File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
    within('.mod-version:nth-child(1)') do
      fill_in 'Number', with: '123'
      fill_in 'Release day', with: 3.weeks.ago
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