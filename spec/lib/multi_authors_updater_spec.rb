require 'rails_helper'

describe MultiAuthorsUpdater do
  subject(:scraper){ MultiAuthorsUpdater.new }

  it { is_expected.to respond_to :update }

  it 'should add the #owner/#author to #authors in the mods' do
    u1 = create :user
    u2 = create :user
    m1 = create :mod, author: u1
    m2 = create :mod, author: u2
    expect(m1.authors).to be_empty
    expect(m2.authors).to be_empty
    subject.update
    m1.reload
    m2.reload
    expect(m1.authors).to eq [u1]
    expect(m2.authors).to eq [u2]
  end

  it 'should create users, using #authors_list, from #author_name in the mods' do
    m1 = create :mod, author_name: 'Potato', author: nil, owner: nil
    m2 = create :mod, author_name: 'Salad', author: nil, owner: nil
    subject.update
    m1.reload
    m2.reload
    u1 = User.find_by_name('Potato')
    u2 = User.find_by_name('Salad')
    expect(m1.authors).to eq [u1]
    expect(m2.authors).to eq [u2]
  end

  it 'should not update mods with non-empty #authors, to prevent accidents' do
    u1 = create :user
    u2 = create :user
    m1 = create :mod, author: u1, authors: [u2]
    subject.update
    m1.reload
    expect(m1.authors).to eq [u2]
  end
end