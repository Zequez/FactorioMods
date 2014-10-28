require 'rails_helper'

module MediaLinks
  describe Imgur do
    describe '.match' do
      it 'should match imgur gallery links' do
        expect(Imgur.match?('http://imgur.com/gallery/qLpt6gI')).to eq true
      end

      it 'should match imgur direct link' do
        expect(Imgur.match?('http://i.imgur.com/O9va9xd.jpg')).to eq true
      end

      it 'should NOT imgur album link' do
        expect(Imgur.match?('http://imgur.com/a/h5Ne0')).to eq false
      end

      it 'should not match whatever else' do
        expect(Imgur.match?('http://google.com')).to eq false
      end

      # http://imgur.com/0EOwT6E?tags
      # http://imgur.com/0EOwT6E
      # http://imgur.com/r/cats/6DS3LT6
    end

    describe '#canonical_url' do
      it 'should return the link to the imgur gallery or whatever' do
        m = Imgur.new('http://imgur.com/gallery/qLpt6gI')
        expect(m.canonical_url).to eq 'http://imgur.com/gallery/qLpt6gI'
      end
    end

    describe '#direct_url' do
      it "should return the direct link to the image appended by jpg because it's the same" do
        m = Imgur.new('http://imgur.com/gallery/caca')
        expect(m.direct_url).to eq 'http://i.imgur.com/caca.jpg'
      end
    end

    describe '#thumbnail_url' do
      it 'should return the direct link to the image thumbnail appended by jpg because its the same' do
        m = Imgur.new('http://imgur.com/gallery/caca')
        expect(m.thumbnail_url).to eq 'http://i.imgur.com/cacas.jpg'
      end
    end

    describe '#embed' do
      it 'should return a <img> tag with the direct URL' do
        m = Imgur.new('http://imgur.com/gallery/caca')
        # Pretty brittle test, but I couldn't think on anything better, sorry
        expect(m.embed.split(/\s+/)).to match_array '<img src="http://i.imgur.com/caca.jpg" class="media-link media-link-imgur" />'.split(/\s+/)
      end
    end
  end
end