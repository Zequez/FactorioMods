# require 'rails_helper'

# module MediaLinks
#   describe Manager do
#     it 'should accept a string as a parameter' do
#       Manager.new('http://imgur.com/gallery/qLpt6gI')
#     end

#     context 'array as an initializer' do
#       it 'should load the correct classes' do
#         m = Manager.new([['Imgur', 'qLpt6gI'], ['Gfycat', 'EthicalZanyHuman']])
#         expect(m.media_links.size).to eq 2
#         expect(m.media_links[0].key).to eq 'qLpt6gI'
#         expect(m.media_links[1].key).to eq 'EthicalZanyHuman'
#       end
#     end

#     context 'empty initializer' do
#       it 'should work' do
#         m = Manager.new('')
#         expect(m.size).to eq 0
#       end
#     end

#     describe '#size' do
#       it 'should return the number of links' do
#         m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#         m.size.should eq 2
#       end
#     end

#     describe '#media_links' do
#        it 'should return an array with the valid media links objects' do
#           m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#           expect(m.media_links.size).to eq 2
#           expect(m.media_links[0]).to be_kind_of Imgur
#           expect(m.media_links[1]).to be_kind_of Gfycat
#        end
#     end

#     describe '#valid_urls' do
#       it 'should return an array with the valid media links strings' do
#         m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#         expect(m.valid_urls.size).to eq 2
#         expect(m.valid_urls[0]).to eq 'http://imgur.com/gallery/qLpt6gI'
#         expect(m.valid_urls[1]).to eq 'http://gfycat.com/EthicalZanyHuman'
#       end
#     end

#     describe '#valid?' do
#       it 'should return true if all links are valid' do
#          m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman")
#          expect(m.valid?).to eq true
#       end

#       it 'should return false if at least a link is invalid' do
#         m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#         expect(m.valid?).to eq false
#       end
#     end

#     describe '#invalid_urls' do
#       it 'should return an array with the invalid media links strings' do
#         m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#         expect(m.invalid_urls.size).to eq 1
#         expect(m.invalid_urls[0]).to eq 'http://caca.com'
#       end
#     end

#     describe '#to_array' do
#       it 'should return an array with the media links' do
#         m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#         m.to_array.should eq [['Imgur', 'qLpt6gI'], ['Gfycat', 'EthicalZanyHuman']]
#       end
#     end

#     describe '#to_string' do
#       it 'should return a string with the media links' do
#         m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#         m.to_string.should eq "http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman"
#       end
#     end

#     describe '.dump' do
#       it 'should dump the array as JSON' do
#         m = Manager.new("http://imgur.com/gallery/qLpt6gI\nhttp://gfycat.com/EthicalZanyHuman\nhttp://caca.com")
#         expect(Manager.dump(m)).to eq '[["Imgur","qLpt6gI"],["Gfycat","EthicalZanyHuman"]]'
#       end

#       it 'should dump an empty array with no media links' do
#         m = Manager.new('rsarsasr\n\nrsasra')
#         expect(Manager.dump(m)).to eq '[]'
#       end
#     end

#     describe '.load' do 
#       it 'should load from a JSON array' do
#         m = Manager.load('[["Imgur","qLpt6gI"],["Gfycat","EthicalZanyHuman"]]')
#         expect(m.media_links.size).to eq 2
#         expect(m.media_links[0]).to be_kind_of Imgur
#         expect(m.media_links[1]).to be_kind_of Gfycat
#       end

#       it 'should load en empty string correctly' do
#         m = Manager.load('')
#         expect(m.size).to eq 0
#       end
#     end
#   end
# end