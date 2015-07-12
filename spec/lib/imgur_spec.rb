require 'rails_helper'

describe Imgur do
  subject(:imgur) { Imgur.new }

  describe '#url', vcr: true do
    it 'should detect that its an image with an image URL' do
      imgur.url = 'http://imgur.com/5xnCbtj'
      expect(imgur.to_s).to eq '5xnCbtj.jpg 5xnCbtj'
      expect(imgur.id).to eq '5xnCbtj'
      expect(imgur.is_album).to eq false
      expect(imgur.extension).to eq 'jpg'
      expect(imgur.thumbnail_url).to eq 'http://i.imgur.com/5xnCbtjs.jpg'
      expect(imgur.valid?).to eq true
    end

    it 'should detect that its an image with an image true URL' do
      imgur.url = 'http://i.imgur.com/5xnCbtj.jpg'
      expect(imgur.to_s).to eq '5xnCbtj.jpg 5xnCbtj'
      expect(imgur.id).to eq '5xnCbtj'
      expect(imgur.is_album).to eq false
      expect(imgur.extension).to eq 'jpg'
      expect(imgur.thumbnail_url).to eq 'http://i.imgur.com/5xnCbtjs.jpg'
      expect(imgur.valid?).to eq true
    end

    it 'should detect that its and album with an album URL' do
      imgur.url = 'http://imgur.com/a/rh3Ie'
      expect(imgur.to_s).to eq 'rh3Ie. baZjbyV'
      expect(imgur.id).to eq 'rh3Ie'
      expect(imgur.is_album).to eq true
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq 'http://i.imgur.com/baZjbyVs.jpg'
      expect(imgur.valid?).to eq true
    end

    it 'should detect its an album with a gallery URL' do
      imgur.url = 'http://imgur.com/gallery/rh3Ie'
      expect(imgur.to_s).to eq 'rh3Ie. baZjbyV'
      expect(imgur.id).to eq 'rh3Ie'
      expect(imgur.is_album).to eq true
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq 'http://i.imgur.com/baZjbyVs.jpg'
      expect(imgur.valid?).to eq true
    end

    it 'should just be invalid' do
      imgur.url = 'http://potato.com/rsatrast'
      expect(imgur.to_s).to eq nil
      expect(imgur.id).to eq nil
      expect(imgur.is_album).to eq nil
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq nil
      expect(imgur.valid?).to eq false
    end

    it 'should be valid with an https domain' do
      imgur.url = 'https://imgur.com/a/rh3Ie'
      expect(imgur.to_s).to eq 'rh3Ie. baZjbyV'
      expect(imgur.id).to eq 'rh3Ie'
      expect(imgur.is_album).to eq true
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq 'http://i.imgur.com/baZjbyVs.jpg'
      expect(imgur.valid?).to eq true
    end

    it 'should be valid without an imgur_url' do
      imgur.url = nil
      expect(imgur.to_s).to eq nil
      expect(imgur.id).to eq nil
      expect(imgur.is_album).to eq nil
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq nil
      expect(imgur.valid?).to eq true
    end

    it 'should de invalid with a 404 image' do
      imgur.url = 'http://imgur.com/asrtniearsthneirasth'
      expect(imgur.to_s).to eq nil
      expect(imgur.id).to eq nil
      expect(imgur.is_album).to eq nil
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq nil
      expect(imgur.valid?).to eq false
    end

    it 'should be invalid without an image_src in the page' do
      # I manually removed the image_src from the cassette recording
      imgur.url = 'http://imgur.com/ai0XTid'
      expect(imgur.to_s).to eq nil
      expect(imgur.id).to eq nil
      expect(imgur.is_album).to eq nil
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq nil
      expect(imgur.valid?).to eq false
    end

    it 'should be invalid if a true image URL is a 404 too' do
      imgur.url = 'http://i.imgur.com/asrtniearsthneirasth.jpg'
      expect(imgur.to_s).to eq nil
      expect(imgur.id).to eq nil
      expect(imgur.is_album).to eq nil
      expect(imgur.extension).to eq nil
      expect(imgur.thumbnail_url).to eq nil
      expect(imgur.valid?).to eq false
    end
  end
end