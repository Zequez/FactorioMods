require 'rails_helper'

include Warden::Test::Helpers

feature 'Modder edits an existing mod' do
  scenario 'submit same basic mod' do
    sign_in
    create_category 'potato'
    mod = create :mod, name: 'Hey', categories: [@category], author: @user
    visit '/mods/hey/edit'
    submit_form
    expect(current_path).to eq '/mods/hey'
    expect(page).to_not have_content('Edit Hey')
  end

  def submit_form
    click_button 'Update Mod'
  end

  def create_category(name)
    @category = create :category, name: name
  end
end