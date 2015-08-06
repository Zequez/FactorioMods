feature 'New user forum account validation' do
  scenario 'user registers, submits the validation form, then visits the link' do
    author = create :author, name: 'FactorioModsBot', forum_name: 'FactorioModsBot'
    another_dude = create :user
    m1 = create :mod, authors: [author], owner: nil
    m2 = create :mod, authors: [author], owner: nil
    create :mod, authors: [author], owner: another_dude
    create :mod, owner: nil

    visit new_user_registration_path
    within '#new_registration' do
      fill_in 'user_email', with: 'potato@universe.com'
      fill_in 'user_forum_name', with: 'FactorioModsBot'
      fill_in 'user_password', with: '12345678'
      find('#user_submit_action input').click
    end

    expect(current_path).to eq new_forum_validation_path

    user = User.last
    expect(user.email).to eq 'potato@universe.com'
    expect(user.forum_name).to eq 'FactorioModsBot'

    VCR.use_cassette("features/forum_validation", record: :new_episodes) do
      find('#forum_validation_submit_action input').click
    end

    fv = ForumValidation.last

    expect(current_path).to eq forum_validation_path fv

    expect(fv.user).to eq user
    expect(fv.author).to eq author
    expect(fv.validated?).to eq false
    expect(fv.pm_sent?).to eq true

    visit update_forum_validation_path(fv, vid: fv.vid)

    expect(current_path).to eq forum_validation_path fv

    fv.reload

    expect(fv.validated?).to eq true
    expect(user.mods).to match_array [m1, m2]
    expect(user.author).to eq author
  end

  scenario "user registers, but the forum_account given doesn't have any author" do
    visit new_user_registration_path
    within '#new_registration' do
      fill_in 'user_email', with: 'potato@universe.com'
      fill_in 'user_forum_name', with: 'FactorioModsBot'
      fill_in 'user_password', with: '12345678'
      find('#user_submit_action input').click
    end

    expect(current_path).to eq root_path
  end
end
