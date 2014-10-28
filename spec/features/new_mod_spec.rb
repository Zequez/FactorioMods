require 'rails_helper'
include Warden::Test::Helpers

feature 'Modder creates a new mod' do
  # scenario 'non-user visits the new mod page' do
  #   visit '/mods/new'

  #   expect(page.status_code).to eq 401
  # end

  # scenario 'user visits new mod page' do
  #   sign_in
  #   visit '/mods/new'

  #   expect(page).to have_content 'Create new mod'
  # end

  # scenario 'user submits an empty form' do
  #   sign_in
  #   visit '/mods/new'
  #   submit_form
  #   expect(page).to have_content 'cannot be empty'
  #   expect(current_path).to eq '/mods'
  # end

  def submit_form
    click_button 'Create Mod'
  end

  def sign_in
    user = create :user
    login_as user
  end
end