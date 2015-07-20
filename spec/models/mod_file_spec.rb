require 'rails_helper'

RSpec.describe ModFile, :type => :model do
  def fixture(name)
    File.new(Rails.root.join('spec', 'fixtures', name))
  end

  subject(:file) { build :mod_file }

  it { expect(file).to respond_to :name }
  it { expect(file).to respond_to :download_url }
  it { expect(file).to respond_to :attachment }
  it { expect(file).to respond_to :mod_version }
  it { expect(file.build_mod_version).to be_kind_of ModVersion }
  it { expect(file).to respond_to :sort_order }
  it { expect(file.sort_order).to be_kind_of Integer }

  describe '#delegated_name' do
    context '#name is populated' do
      it 'should return the name' do
        file.name = 'Potato Chips'
        file.delegated_name.should eq 'Potato Chips'
      end
    end

    context '#name is blank' do
      it 'should return #mod_version.name' do
        file.name = nil
        file.mod_version.number = '1.3.4.5.6'
        file.delegated_name.should eq '1.3.4.5.6'
      end
    end
  end

  describe '#available_url' do
    context 'There is both a #download_url and an #attachment' do
      subject(:file) { build :mod_file, download_url: 'http://potato.com' }
      it { expect(file.available_url).to eq 'http://potato.com' }
    end

    context 'There is a #download_url but not an #attachment' do
      subject(:file) { build :mod_file, download_url: 'http://potato.com', attachment: nil }
      it { expect(file.available_url).to eq 'http://potato.com' }
    end

    context 'There is no #download_url but there is an #attachment' do
      subject(:file) { build :mod_file, download_url: nil }
      it { expect(file.available_url).to eq file.attachment.url}
    end

    context '#download_url is blank and there is an attachment #attachment' do
      subject(:file) { build :mod_file, download_url: '' }
      it { expect(file.available_url).to eq file.attachment.url}
    end

    context 'There is neither a #download_url nor an #attachment' do
      subject(:file) { build :mod_file, download_url: nil, attachment: nil }
      it { expect(file.available_url).to eq ''}
    end
  end

  describe 'validation' do
    it { should validate_attachment_size(:attachment).less_than(20.megabytes) }

    context 'an image instead of a zip file' do
      it 'should not be valid' do
        file.attachment = fixture('test.jpg')
        expect(file).to be_invalid
      end
    end

    context 'a zip file' do
      it 'should be valid' do
        file.attachment = fixture('test.zip')
        expect(file).to be_valid
      end
    end

    it 'should be valid withoua a #mod_version' do
      file.mod_version = nil
      file.name = nil
      expect(file).to be_valid
      expect(file.name).to eq nil
      expect(file.delegated_name).to eq nil
    end

    it 'should be invalid with no #attachment or #download_url' do
      file.attachment = nil
      file.download_url = nil
      expect(file).to be_invalid
    end

    it 'should be valid with no #attachment but with #download_url' do
      file = build :mod_file, attachment: nil, download_url: 'https://github.com/Dysoch/DyTech/archive/v1.1.3-core.zip'
      expect(file).to be_valid
    end

    it 'should be invalid if the #download_url is not an URL' do
      file = build :mod_file, download_url: 'javascript:alert("D:");'
      expect(file).to be_invalid
    end
  end
end
