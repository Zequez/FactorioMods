require 'rails_helper'

include Warden::Test::Helpers

feature 'Redirect to the previous page the user was after login' do
  scenario 'user is viewing a mod, and clicks on login, then he submits the login form' do
    user = create :user, name: 'Potato', email: 'banana@split.com', password: 'rsarsarsa'
    mod = create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Login'
    expect(current_path).to eq '/users/login'
    fill_in 'Email', with: 'banana@split.com'
    fill_in 'Password', with: 'rsarsarsa'
    click_button 'Login'
    expect(current_path).to eq '/mods/hey'
  end

  scenario 'user fails to login first, and then tries again' do
    user = create :user, name: 'Potato', email: 'banana@split.com', password: 'rsarsarsa'
    mod = create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Login'
    expect(current_path).to eq '/users/login'
    fill_in 'Email', with: 'banana@split.com'
    fill_in 'Password', with: 'nooooooooooooo'
    click_button 'Login'
    expect(current_path).to eq '/users/login'
    fill_in 'Email', with: 'banana@split.com'
    fill_in 'Password', with: 'rsarsarsa'
    click_button 'Login'
    expect(current_path).to eq '/mods/hey'
  end

  scenario 'user is viewing a mod, and clicks on register, and then registers successfully' do
    mod = create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Register'
    expect(current_path).to eq '/users/register'
    find('#user_email').set 'banana@split.com'
    find('#user_name').set 'PotatoHead'
    find('#user_password').set 'rsarsarsa'
    find('#user_password_confirmation').set 'rsarsarsa'
    click_button 'Register'
    expect(current_path).to eq '/mods/hey'
  end

  scenario 'user is viewing a mod, and clicks on register, and then fails, and then tries again' do
    mod = create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Register'
    expect(current_path).to eq '/users/register'
    find('#user_email').set 'banana@split.com'
    find('#user_name').set 'INVALID USERNAME!!!'
    find('#user_password').set 'rsarsarsa'
    find('#user_password_confirmation').set 'rsarsarsa'
    click_button 'Register'
    expect(current_path).to eq '/users'
    find('#user_email').set 'banana@split.com'
    find('#user_name').set 'PotatoHead'
    find('#user_password').set 'rsarsarsa'
    find('#user_password_confirmation').set 'rsarsarsa'
    click_button 'Register'
    expect(current_path).to eq '/mods/hey'
  end
end