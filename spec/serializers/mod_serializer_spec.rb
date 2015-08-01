require 'rails_helper'

describe ModSerializer do
  before :each do
    authors = [create(:user, name: 'John Snow Zombie'), create(:user, name: 'THAT Guy')]
    @mod = create :mod,
      name: 'Potato Galaxy',
      info_json_name: 'potato-galaxy-mod',
      authors: authors,
      contact: 'Send a homing pigeon to Castle Black',
      official_url: 'http://castleblack.com',
      summary: 'This mod adds the ability to farm potatoes on Factorio.',
      categories: [create(:category, name: 'Potato'), create(:category, name: 'Apple')]
  end

  it 'should return the public API structure' do
    expect(ModSerializer.new(@mod).as_json).to eq({
      id: @mod.id,
      title: 'Potato Galaxy',
      name: 'potato-galaxy-mod',
      url: 'http://localhost:3000/mods/potato-galaxy',
      description: 'This mod adds the ability to farm potatoes on Factorio.',
      homepage: 'http://castleblack.com',
      contact: 'Send a homing pigeon to Castle Black',
      authors: ['John Snow Zombie', 'THAT Guy'],
      categories: ['potato', 'apple'],
      releases: @mod.versions.map{|mv| ModVersionSerializer.new mv}.as_json
    })

  end
end
