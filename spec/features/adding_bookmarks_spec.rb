require 'rails_helper'

feature 'User creates and removes bookmarks' do
  include Warden::Test::Helpers

  scenario 'logged in user adds a bookmark', js: true do
    create :mod
    create :mod
    create :mod
    sign_in create(:user)
    visit '/mods'
    expect(all('.mods-bookmark-create').size).to eq 3
    expect(all('.mods-bookmark-destroy').size).to eq 0
    all('.mods-bookmark-create')[1].click
    visit '/mods'
    expect(all('.mods-bookmark-create').size).to eq 2
    expect(all('.mods-bookmark-destroy').size).to eq 1
  end
end
