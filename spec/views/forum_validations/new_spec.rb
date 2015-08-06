describe 'forum_validations/new', type: :view do
  it 'should render the mods associated with the author' do
    fv = create :forum_validation
    create :mod, authors: [fv.author], name: 'Potato'
    create :mod, authors: [fv.author], name: 'Galaxy'
    create :mod, authors: [fv.author], name: 'Simulator'
    assign(:forum_validation, fv)
    render
    expect(rendered).to match(/Potato.*Galaxy.*Simulator/m)
    expect(rendered).to have_selector("#forum_validation_author_id[value=\"#{fv.author_id}\"]")
  end
end
