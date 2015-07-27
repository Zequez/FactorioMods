require 'rails_helper'
include Warden::Test::Helpers

feature 'Modder edits an existing mod' do
  scenario 'submit same basic mod' do
    sign_in
    create_category 'potato'
    mod = create :mod, name: 'Hey', categories: [@category], owner: @user
    visit '/mods/hey/edit'
    submit_form
    expect(current_path).to eq '/mods/hey'
    expect(page).to_not have_content('Edit Hey')
  end

  scenario 'user edits a mod with a list of authors' do
    sign_in_dev
    create_category 'potato'
    authors = 5.times.map{ create :user }
    mod = create :mod, name: 'Hey', categories: [@category], owner: @user, authors: authors
    visit '/mods/hey/edit'
    expect(find('#mod_authors_list').value).to eq authors.map(&:name).join(', ')
  end

  def submit_form
    click_button 'Update Mod'
  end

  def create_category(name)
    @category = create :category, name: name
  end
end