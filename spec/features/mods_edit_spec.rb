include Warden::Test::Helpers

feature 'Modder edits an existing mod' do
  scenario 'submit same basic mod' do
    sign_in
    create_category 'potato'
    create :mod, name: 'Hey', categories: [@category], owner: @user
    visit '/mods/hey/edit'
    submit_form
    expect(current_path).to eq '/mods/hey'
    expect(page).to_not have_content('Edit Hey')
  end

  scenario 'admin edits a mod with an author' do
    sign_in_admin
    create_category 'potato'
    author = create :author
    create :mod, name: 'Hey', categories: [@category], author: author
    visit '/mods/hey/edit'
    expect(find('#mod_author_name').value).to eq author.name
  end

  def submit_form
    click_button 'Update Mod'
  end

  def create_category(name)
    @category = create :category, name: name
  end
end
