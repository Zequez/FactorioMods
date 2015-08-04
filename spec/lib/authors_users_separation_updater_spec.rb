describe AuthorsUsersSeparationUpdater do
  subject(:updater){ AuthorsUsersSeparationUpdater.new }

  # users and mods are currently associated with the authors_mods table
  # now the authors_mods table is used by the authors table instead of the users

  # To run the migration we need to:
  # - All the autogenerated users should be *removed* from the users table
  #   and should be added to the authors table, using the user name as name
  #   and as forum_name. To do this we need create a new author for each user
  #   and after we create the author, we should get the all the authors_mods
  #   entries with that user.id and update them with the author id.
  # - All the non-autogenerated users should be *copied* to the authors table
  #   and update all the authors_mods entries from the user.id to the newly
  #   created author.id
  #   After this we need to check if the mods associated with the author
  #   are also owned by the user. If so, then we validate the user by
  #   associating the author with the user.

  # before :each do
  #   u1 = User.autogenerate(name: 'Potato')
  #   u2 = User.autogenerate(name: 'Galaxy')
  #   u3 = create :user, name: 'Simulator'
  #   u1.save!
  #   u2.save!
  #
  #   m1 = create :mod, owner: nil, authors: []
  #   m2 = create :mod, owner: u3, authors: []
  #
  #   create :authors_mod, mod_id: m1.id, author_id: u1.id
  #   create :authors_mod, mod_id: m1.id, author_id: u2.id
  #
  #   create :authors_mod, mod_id: m2.id, author_id: u2.id
  # end

  it 'should move all the autogenerated users to the authors table' do
    u1 = User.autogenerate(name: 'Potato')
    u2 = User.autogenerate(name: 'Galaxy')
    u1.save!
    u2.save!

    m1 = create :mod, owner: nil, authors: []
    m2 = create :mod, owner: nil, authors: []

    create :authors_mod, mod_id: m1.id, author_id: u1.id
    create :authors_mod, mod_id: m1.id, author_id: u2.id
    create :authors_mod, mod_id: m2.id, author_id: u1.id

    # Mod1 has 2 autogenerated users, user1 and user2 that need to be moved
    # Mod2 has 1 autogenerated user1 that need to be moved

    expect(m1.authors).to eq []
    expect(m2.authors).to eq []

    expect(User.pluck(:name)).to eq %w{Potato Galaxy}
    expect(Author.pluck(:name)).to eq []
    updater.run
    expect(User.pluck(:name)).to eq []
    expect(Author.pluck(:name)).to eq %w{Potato Galaxy}

    m1.reload
    m2.reload

    expect(m1.authors.map(&:name)).to eq %w{Potato Galaxy}
    expect(m2.authors.map(&:name)).to eq %w{Potato}

    expect(User.find_by_id u1.id).to eq nil
    expect(User.find_by_id u2.id).to eq nil
  end

  it 'should not remove users that were not autogenerated' do
    u1 = User.autogenerate(name: 'Potato')
    u1.save!
    u2 = create :user, name: 'Galaxy'

    m1 = create :mod, owner: nil, authors: []
    m2 = create :mod, owner: nil, authors: []

    create :authors_mod, mod_id: m1.id, author_id: u1.id
    create :authors_mod, mod_id: m1.id, author_id: u2.id
    create :authors_mod, mod_id: m2.id, author_id: u1.id

    # Mod1 has 2 autogenerated users, user1 that needs to be moved, and user2 that need to copied
    # Mod2 has 1 autogenerated user1 that need to be moved

    expect(m1.authors).to eq []
    expect(m2.authors).to eq []

    expect(User.pluck(:name)).to eq %w{Potato Galaxy}
    expect(Author.pluck(:name)).to eq []
    updater.run
    expect(User.pluck(:name)).to eq %w{Galaxy}
    expect(Author.pluck(:name)).to eq %w{Potato Galaxy}

    m1.reload
    m2.reload

    expect(m1.authors.map(&:name)).to eq %w{Potato Galaxy}
    expect(m2.authors.map(&:name)).to eq %w{Potato}

    expect(User.find_by_id u1.id).to eq nil
    expect(User.find_by_id u2.id).to eq u2
  end

  it 'should associate the user and the author if the user is owner of the mod' do
    u1 = create :user, name: 'Potato'
    u2 = create :user, name: 'Galaxy'
    u3 = User.autogenerate name: 'Simulator'
    u3.save!

    m1 = create :mod, owner: u1, authors: []
    m2 = create :mod, owner: u3, authors: []
    m3 = create :mod, owner: nil, authors: []

    create :authors_mod, mod_id: m1.id, author_id: u1.id
    create :authors_mod, mod_id: m1.id, author_id: u2.id
    create :authors_mod, mod_id: m2.id, author_id: u1.id
    create :authors_mod, mod_id: m3.id, author_id: u3.id

    expect(User.pluck(:name)).to eq %w{Potato Galaxy Simulator}
    expect(Author.pluck(:name)).to eq []
    updater.run
    expect(User.pluck(:name)).to eq %w{Potato Galaxy}
    expect(Author.pluck(:name)).to eq %w{Potato Galaxy Simulator}

    m1.reload
    m2.reload
    m3.reload

    expect(m1.authors.map(&:name)).to eq %w{Potato Galaxy}
    expect(m2.authors.map(&:name)).to eq %w{Potato}
    expect(m3.authors.map(&:name)).to eq %w{Simulator}
    expect(m1.owner).to eq u1
    expect(m2.owner).to eq nil
    expect(m3.owner).to eq nil

    u1.reload
    u2.reload
    expect(User.find_by_id u3.id).to eq nil

    a1 = Author.find_by_name('Potato')
    a2 = Author.find_by_name('Galaxy')
    a3 = Author.find_by_name('Simulator')

    expect(a1.user).to eq u1
    expect(a2.user).to eq nil
    expect(a3.user).to eq nil

    expect(a1.mods).to eq [m1, m2]
    expect(a2.mods).to eq [m1]
    expect(a3.mods).to eq [m3]
  end
end