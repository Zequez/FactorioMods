describe 'forum_validations/show', type: :view do
  before :each do
    @fv = create :forum_validation
    create :mod, authors: [@fv.author], name: 'Potato'
    create :mod, authors: [@fv.author], name: 'Salad'
    create :mod, authors: [@fv.author], name: 'Simulator'
  end

  it 'display the list of mods associated with the author' do
    assign(:forum_validation, @fv)
    render
    expect(rendered).to match(/Potato.*Salad.*Simulator/m)
  end

  context '#validated = false' do
    it 'should display a message indicating that the user is not validated' do
      @fv.validated = false
      assign(:forum_validation, @fv)
      render
      expect(rendered).to include I18n.t('forum_validations.show.not_validated')
    end
  end

  context '#validated = true' do
    it 'should display a message indicating that the user is validated' do
      @fv.validated = true
      assign(:forum_validation, @fv)
      render
      expect(rendered).to include I18n.t('forum_validations.show.validated')
    end

    it 'should display links to edit each the mods' do
      @fv.validated = true
      assign(:forum_validation, @fv)
      render
      expect(rendered).to have_link('', href: edit_mod_path(id: 'potato'))
      expect(rendered).to have_link('', href: edit_mod_path(id: 'salad'))
      expect(rendered).to have_link('', href: edit_mod_path(id: 'simulator'))
    end
  end
end
