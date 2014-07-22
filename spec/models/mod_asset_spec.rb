require 'rails_helper'

RSpec.describe ModAsset, :type => :model do
  def fixture_image
    File.new(Rails.root.join('spec', 'fixtures', 'test.jpg'))
  end

  subject(:asset) { build :mod_asset }

  describe 'attributes' do

    describe '#image' do
      it { expect(asset).to respond_to :image }

      it 'should be able to save an image with paperclip' do
        asset = build :mod_asset, image: fixture_image
        asset.save!
      end
    end

    it { expect(asset).to respond_to :version }
    it { expect(asset).to respond_to :video_url }

    describe '#video?' do
      it 'should be false when #video_url is blank' do
        asset.video_url = ''
        expect(asset.video?).to eq false
      end

      it 'should be true when #video_url is not empty' do
        asset.video_url = 'http://www.youtube.com/watch?v=C0DPdy98e4c'
        expect(asset.video?).to eq true
      end
    end

    describe '#video_provider' do
      it "should return :youtube when it's a YouTube video" do
        asset.video_url = 'http://www.youtube.com/watch?v=C0DPdy98e4c'
        asset.video_provider.should eq :youtube
      end

      it 'should return :unknown if no valid video provider identified' do
        asset.video_url = 'http://potato.com'
        asset.video_provider.should eq :unknown
      end
    end

    describe '#video_embed_url' do
      it "should return the YouTube embed URL if it's a YouTube video" do
        asset.video_url = 'http://www.youtube.com/watch?v=C0DPdy98e4c'
        expect(asset.video_embed_url).to eq 'http://www.youtube.com/embed/C0DPdy98e4c'
      end

      it 'should return nil if not a valid video' do
        asset.video_url = 'http://potato.com'
        asset.video_embed_url.should eq nil
      end
    end

    describe '#version_number' do
      it 'should delegate the version number to #version' do
        asset.version = build :mod_version, number: '1.5.7'
        asset.version_number.should eq '1.5.7'
      end
    end

    describe '#sort_order' do
      it { expect(asset).to respond_to :sort_order }
      it { expect(asset.sort_order).to be_kind_of Integer }
    end
  end

  describe 'validation' do
    context 'empty image, empty video' do
      it 'should not be valid' do
        asset.image = nil
        asset.video_url = ''

        expect(asset.valid?).to eq false
      end
    end

    context 'empty image, valid video' do
      it 'should be valid' do
        asset.image = nil
        asset.video_url = 'http://www.youtube.com/watch?v=C0DPdy98e4c'

        expect(asset.valid?).to eq true
      end
    end

    context 'valid image, empty video' do
      it 'should be valid' do
        asset.image = fixture_image
        asset.video_url = ''

        expect(asset.valid?).to eq true
      end
    end

    context 'valid image, valid video' do
      it 'should not be valid' do
        asset.image = fixture_image
        asset.video_url = 'http://www.youtube.com/watch?v=C0DPdy98e4c'

        expect(asset.valid?).to eq false
      end
    end

    context 'invalid video' do
      it 'should not be valid' do
        asset.image = nil
        asset.video_url = 'http://potato.com'

        expect(asset.valid?).to eq false
      end
    end
  end
end
