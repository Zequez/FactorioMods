describe 'forum_validations/new', type: :view do
  it 'should render the mods associated with the author' do
    fv = create :forum_validation
    create :mod, author: fv.author, name: 'Potato'
    create :mod, author: fv.author, name: 'Galaxy'
    create :mod, author: fv.author, name: 'Simulator'
    assign(:forum_validation, fv)
    render
    expect(rendered).to match(/Potato/)
    expect(rendered).to match(/Galaxy/)
    expect(rendered).to match(/Simulator/)
    expect(rendered).to have_selector("#forum_validation_author_id[value=\"#{fv.author_id}\"]")
  end
end
