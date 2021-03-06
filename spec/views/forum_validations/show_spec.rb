describe 'forum_validations/show', type: :view do
  before :each do
    @fv = create :forum_validation
    @m1 = create :mod, author: @fv.author, name: 'Potato'
    @m2 = create :mod, author: @fv.author, name: 'Salad'
    @m3 = create :mod, author: @fv.author, name: 'Simulator'
  end

  it 'display the list of mods associated with the author' do
    assign(:forum_validation, @fv)
    render
    expect(rendered).to match(/Potato/)
    expect(rendered).to match(/Salad/)
    expect(rendered).to match(/Simulator/)
  end

  context '#validated = false' do
    it 'should display a message indicating that the user is not validated' do
      @fv.validated = false
      assign(:forum_validation, @fv)
      render
      expect(rendered).to include I18n.t('forum_validations.show.not_validated')
    end

    it 'should NOT display links to edit each the mods' do
      @fv.validated = false
      assign(:forum_validation, @fv)
      render
      expect(rendered).to_not have_link('', href: edit_mod_path(id: 'potato'))
      expect(rendered).to_not have_link('', href: edit_mod_path(id: 'salad'))
      expect(rendered).to_not have_link('', href: edit_mod_path(id: 'simulator'))
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

  context '#pm_sent = false' do
    it 'should display a message indicating that the PM could not be sent' do
      @fv.pm_sent = false
      assign(:forum_validation, @fv)
      render
      expect(rendered).to include I18n.t('forum_validations.show.pm_not_sent')
    end
  end

  context '#pm_sent = true' do
    it 'should not display the pm_not_sent error message' do
      @fv.pm_sent = true
      assign(:forum_validation, @fv)
      render
      expect(rendered).to_not include I18n.t('forum_validations.show.pm_not_sent')
    end
  end
end
