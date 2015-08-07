feature 'Common sign in and sign up form everywhere' do
  scenario 'login should have also a registration form', js: true do
    visit new_user_session_path
    expect(page).to     have_field 'user_login'
    expect(page).to_not have_field 'user_email'
    expect(page).to_not have_field 'user_name'
    expect(page).to     have_field 'user_password'
    expect(page).to_not have_field 'user_password_confirmation'
    expect(page).to     have_field 'user_remember_me'
    page.find('[for="identify_register"]').click
    expect(page).to_not have_field 'user_login'
    expect(page).to     have_field 'user_email'
    expect(page).to     have_field 'user_name'
    expect(page).to     have_field 'user_password'
    expect(page).to_not have_field 'user_password_confirmation'
    expect(page).to     have_field 'user_remember_me'
  end
end
