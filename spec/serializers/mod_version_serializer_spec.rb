require 'rails_helper'

describe ModVersionSerializer do
  before :each do
    gv1 = create :game_version, number: '0.10.x'
    gv2 = create :game_version, number: '0.11.x'
    gv3 = create :game_version, number: '0.12.x'

    @mv1 = create :mod_version,
      number: '1.2.1',
      released_at: 1.month.ago,
      game_versions: [gv1],
      files: [
        build(:mod_file, name: '', download_url: 'http://thepotatoexperience.com/1.2.1', attachment: nil)
      ]
    @mv2 = create :mod_version,
      number: '1.2.2',
      released_at: 2.weeks.ago,
      game_versions: [gv2, gv3],
      files: [
        build(:mod_file, name: 'win', download_url: 'http://thepotatoexperience.com/1.2.2', attachment: nil),
        build(:mod_file, name: 'mac', download_url: 'http://thepotatoexperience.com/1.2.2', attachment: nil)
      ]
    @mv3 = create :mod_version,
      number: '1.2.3',
      released_at: 1.week.ago,
      game_versions: [gv3],
      files: [
        build(:mod_file,
          name: '',
          download_url: 'http://thepotatoexperience.com/1.2.3',
          attachment: File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
        )
      ]
  end

  it 'should return the public API structure' do
    expect(ModVersionSerializer.new(@mv1).as_json).to eq({
      id: @mv1.id,
      version: '1.2.1',
      released_at: @mv1.released_at,
      game_versions: ['0.10.x'],
      dependencies: [],
      files: @mv1.files.map{|mf| ModFileSerializer.new mf}.as_json
      # files: [
      #   { name: '', url: 'http://thepotatoexperience.com/1.2.1', mirror: '' }
      # ]
    })
    expect(ModVersionSerializer.new(@mv2).as_json).to eq({
      id: @mv2.id,
      version: '1.2.2',
      released_at: @mv2.released_at,
      game_versions: ['0.11.x', '0.12.x'],
      dependencies: [],
      files: @mv2.files.map{|mf| ModFileSerializer.new mf}.as_json
    })
    expect(ModVersionSerializer.new(@mv3).as_json).to eq({
      id: @mv3.id,
      version: '1.2.3',
      released_at: @mv3.released_at,
      game_versions: ['0.12.x'],
      dependencies: [],
      files: @mv3.files.map{|mf| ModFileSerializer.new mf}.as_json
      #   {
      #     name: '',
      #     url: 'http://thepotatoexperience.com/1.2.3',
      #     mirror: @mod.versions[0].files.first.attachment.url
      #   }
      # ]
    })
      # {
      #   id: @mod.versions[0].id,
      #   version: '1.2.2',
      #   released_at: @mod.versions[1].released_at,
      #   game_versions: ['0.11.x', '0.12.x'],
      #   dependencies: [],
      #   files: [
      #     { name: 'mac', url: 'http://thepotatoexperience.com/1.2.2', mirror: '' },
      #     { name: 'win', url: 'http://thepotatoexperience.com/1.2.2', mirror: '' }
      #   ]
      # },
      # {
      #   id: @mod.versions[0].id,
      #   version: '1.2.1',
      #   released_at: @mod.versions[2].released_at,
      #   game_versions: ['0.10.x'],
      #   dependencies: [],
      #   files: [
      #     { name: '', url: 'http://thepotatoexperience.com/1.2.1', mirror: '' }
      #   ]
      # }
  end
end
