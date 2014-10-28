require 'rails_helper'

module MediaLinks
  describe Gfycat do
    describe '.match' do
      it 'should match Gfycat regular links' do
        expect(Gfycat.match?('http://gfycat.com/EthicalZanyHuman')).to eq true
      end

      it 'should not match whatever else' do
        expect(Gfycat.match?('http://google.com')).to eq false
      end
    end

    describe '#canonical_url' do
      it 'should return the link to the imgur gallery or whatever' do
        m = Gfycat.new('http://gfycat.com/EthicalZanyHuman')
        expect(m.canonical_url).to eq 'http://gfycat.com/EthicalZanyHuman'
      end
    end

    describe '#direct_url' do
      it "should return the direct link to the image appended by jpg because it's the same" do
        m = Gfycat.new('http://gfycat.com/EthicalZanyHuman')
        expect(m.direct_url).to eq 'http://gfycat.com/ifr/EthicalZanyHuman'
      end
    end

    describe '#thumbnail_url' do
      it 'should return the direct link to the image thumbnail appended by jpg because its the same' do
        m = Gfycat.new('http://gfycat.com/EthicalZanyHuman')
        expect(m.thumbnail_url).to eq 'https://thumbs.gfycat.com/EthicalZanyHuman-poster.jpg'
      end
    end

    describe '#embed' do
      it 'should return an <iframe> tag with the direct URL' do
        m = Gfycat.new('http://gfycat.com/EthicalZanyHuman')
        # Pretty brittle test, but I couldn't think on anything better, sorry
        expect(m.embed.split(/\s/)).to match_array '<iframe src="http://gfycat.com/ifr/EthicalZanyHuman" class="media-link media-link-gfycat" />'.split(/\s+/)
      end
    end
  end
end