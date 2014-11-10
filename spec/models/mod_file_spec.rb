require 'rails_helper'

RSpec.describe ModFile, :type => :model do
  def fixture(name)
    File.new(Rails.root.join('spec', 'fixtures', name))
  end

  subject(:file) { build :mod_file }

  it { expect(file).to respond_to :name }

  describe '#mod_version' do
    it { expect(file).to respond_to :mod_version }
    it 'should be kind of ModVersion' do
      file.build_mod_version
      expect(file.mod_version).to be_kind_of ModVersion
    end
  end

  describe '#attached_file' do
    it { expect(file).to respond_to :attachment }

    it 'should save with the attachment' do
      file.attachment = fixture('test.zip')
      expect(file.save).to eq true
    end
  end

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

  describe '#sort_order' do
    it { expect(file).to respond_to :sort_order }
    it { expect(file.sort_order).to be_kind_of Integer }
  end

  describe 'validation' do
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

    context 'empty #mod_version' do
      it 'should be valid' do
        file.mod_version = nil
        file.name = nil
        expect(file).to be_valid
        expect(file.name).to eq nil
        expect(file.delegated_name).to eq nil
      end
    end
  end
end
