include Warden::Test::Helpers

feature 'Redirect to the previous page the user was after login' do
  scenario 'user is viewing a mod, and clicks on login, then he submits the login form' do
    create :user, name: 'Potato', email: 'banana@split.com', password: 'rsarsarsa'
    create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Login'
    expect(current_path).to eq '/users/login'
    within('#new_session') do
      fill_in 'user_login', with: 'banana@split.com'
      fill_in 'user_password', with: 'rsarsarsa'
      click_button 'Login'
    end
    expect(current_path).to eq '/mods/hey'
  end

  scenario 'user fails to login first, and then tries again' do
    create :user, name: 'Potato', email: 'banana@split.com', password: 'rsarsarsa'
    create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Login'
    expect(current_path).to eq '/users/login'
    within('#new_session') do
      fill_in 'user_login', with: 'banana@split.com'
      fill_in 'user_password', with: 'nooooooooooooo'
      click_button 'Login'
    end
    expect(current_path).to eq '/users/login'
    within('#new_session') do
      fill_in 'user_login', with: 'banana@split.com'
      fill_in 'user_password', with: 'rsarsarsa'
      click_button 'Login'
    end
    expect(current_path).to eq '/mods/hey'
  end

  scenario 'user is viewing a mod, and clicks on register, and then registers successfully' do
    create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Register'
    expect(current_path).to eq '/users/register'
    within('#new_registration') do
      fill_in 'user_email', with: 'banana@split.com'
      fill_in 'user_password', with: 'rsarsarsa'
      click_button 'Register'
    end
    expect(current_path).to eq '/mods/hey'
  end

  scenario 'user is viewing a mod, and clicks on register, and then fails, and then tries again' do
    create :mod, name: 'Hey'
    visit '/mods/hey'
    click_link 'Register'
    expect(current_path).to eq '/users/register'
    within('#new_registration') do
      fill_in 'user_email', with: 'bansplit.com'
      fill_in 'user_password', with: 'rsarsarsa'
      click_button 'Register'
    end
    expect(current_path).to eq '/users'
    within('#new_registration') do
      fill_in 'user_email', with: 'banana@split.com'
      fill_in 'user_password', with: 'rsarsarsa'
      click_button 'Register'
    end
    expect(current_path).to eq '/mods/hey'
  end
end
