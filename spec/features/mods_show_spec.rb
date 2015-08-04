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
    create :mod, name: 'Super Mod', categories: [category], owner: @user
    visit '/mods/super-mod'
    expect(page).to have_link 'Edit mod', '/mods/super-mod/edit'
  end

  scenario 'Visiting the mod page as a guest should not display a link to edit the mod' do
    sign_in
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category], owner: build(:user)
    visit '/mods/super-mod'
    expect(page).to_not have_link 'Edit mod', '/mods/super-mod/edit'
  end

  scenario 'Visiting the mod page as an admin display a link to edit the mod regardless of the owner' do
    sign_in
    @user.is_admin = true
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', categories: [category], owner: build(:user)
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

  # TODO: Using the sign in helpers and this breaks all the other tests
  # that require the user to be logged in for some reason. Fix with a proper
  # helper to login on integration tests. Or move these to views tests.

  # scenario 'Mod with multiple authors' do
  #   authors = 5.times.map{ |i| create :author, name: "Au#{i}" }
  #   mod = create :mod, name: 'SuperMod', authors: authors
  #   visit '/mods/supermod'
  #   expect(page.html).to include(mod.decorate.authors_links_list)
  # end

  describe 'visibility' do
    scenario 'non-dev owner visits his own mod' do
      user = create :user
      mod = create :mod, owner: user, visible: false
      sign_in user
      visit mod_path mod
      expect(page).to have_http_status :success
      expect(page).to have_content I18n.t('mods.show.non_visible.non_dev')
    end

    scenario 'dev owner visits his own mod' do
      user = create :user, is_dev: true
      mod = create :mod, owner: user, visible: false
      sign_in user
      visit mod_path mod
      expect(page).to have_http_status :success
      expect(page).to have_content I18n.t('mods.show.non_visible.dev')
    end

    scenario 'a non-registered user visits a non-visible mod' do
      mod = create :mod, visible: false
      visit mod_path mod
      expect(current_path).to eq new_user_session_path
    end

    scenario 'a registered user visits a non-visible mod' do
      user = create :user
      sign_in user
      mod = create :mod, visible: false
      visit mod_path mod
      expect(page).to have_http_status :unauthorized
    end

    scenario 'a dev user visits a non-visible mod' do
      user = create :user, is_dev: true
      sign_in user
      mod = create :mod, visible: false
      visit mod_path mod
      expect(page).to have_http_status :unauthorized
    end

    scenario 'admin visits some guy non-visible mod' do
      some_guy = create :user, is_dev: true
      mod = create :mod, owner: some_guy, visible: false
      admin = create :user, is_admin: true
      sign_in admin
      visit mod_path mod
      expect(page).to have_http_status :success
      expect(page).to have_content I18n.t('mods.show.non_visible.admin')
    end

    scenario 'admin visits an ownerless non-visible mod' do
      mod = create :mod, owner: nil, visible: false
      admin = create :user, is_admin: true
      sign_in admin
      visit mod_path mod
      expect(page).to have_http_status :success
      expect(page).to have_content I18n.t('mods.show.non_visible.admin')
    end
  end
end
