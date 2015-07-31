require 'rails_helper'

describe ModFileSerializer do
  def serialized(params)
    @mf = create :mod_file, params
    ModFileSerializer.new(@mf).as_json
  end

  before :each do
    @mf1 = create :mod_file,
      name: 'win',
      download_url: 'http://thepotatoexperience.com/1.2.2',
      attachment: nil
    @mf1 = create :mod_file,
      name: 'mac',
      download_url: 'http://thepotatoexperience.com/1.2.2',
      attachment: nil
    @mf1 = create :mod_file,
      name: '',
      download_url: 'http://thepotatoexperience.com/1.2.3',
      attachment: File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
  end

  it 'should serialize NO #name & #download_url & NO #attachment' do
    expect(serialized(
      name: '',
      download_url: 'http://thepotatoexperience.com/1.2.1',
      attachment: nil
    )).to eq({
      id: @mf.id,
      name: '',
      url: 'http://thepotatoexperience.com/1.2.1',
      mirror: nil
    })
  end

  it 'should serialize #name & #download_url & #attachment' do
    expect(serialized(
      name: 'win',
      download_url: 'http://thepotatoexperience.com/1.2.1',
      attachment: File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
    )).to eq({
      id: @mf.id,
      name: 'win',
      url: 'http://thepotatoexperience.com/1.2.1',
      mirror: @mf.attachment.url
    })
  end

  it 'should serialize #name & NO #download_url & #attachment' do
    expect(serialized(
      name: 'mac',
      download_url: '',
      attachment: File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
    )).to eq({
      id: @mf.id,
      name: 'mac',
      url: nil,
      mirror: @mf.attachment.url
    })
  end
end
