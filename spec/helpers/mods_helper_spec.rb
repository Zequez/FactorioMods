require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ModsHelper. For example:
#
# describe ModsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ModsHelper, :type => :helper do
  describe '#link_to_file_url_with_name' do
    it 'should return a link to the download URL if available' do
      file = build :mod_file, download_url: 'https://github.com/Dysoch/DyTech/archive/v1.1.3-core.zip', attachment: nil
      expect(link_to_file_url_with_name(file))
        .to eq '<a href="https://github.com/Dysoch/DyTech/archive/v1.1.3-core.zip">v1.1.3-core.zip</a>'
    end

    it 'should add a mirror if both are available' do
      file = build :mod_file, download_url: 'https://github.com/Dysoch/DyTech/archive/v1.1.3-core.zip'
      expect(link_to_file_url_with_name(file))
        .to eq "<a href=\"https://github.com/Dysoch/DyTech/archive/v1.1.3-core.zip\">#{file.attachment_file_name}</a> (<a href=\"#{file.attachment.url}\">Mirror</a>)"
    end

    it 'should return a link to the attachment URL if there is no download URL' do
      file = build :mod_file, download_url: nil
      expect(link_to_file_url_with_name(file))
        .to eq "<a href=\"#{file.attachment.url}\">#{file.attachment_file_name} (#{number_to_human_size(file.attachment_file_size)})</a>"
    end
    it 'should return a link to the attachment URL if the download URL is an empty string' do
      file = build :mod_file, download_url: ''
      expect(link_to_file_url_with_name(file))
        .to eq "<a href=\"#{file.attachment.url}\">#{file.attachment_file_name} (#{number_to_human_size(file.attachment_file_size)})</a>"
    end

    it 'should return nil with an invalid URI' do
      file = build :mod_file, download_url: 'http://github.com/javascript:alert("Yes")', attachment: nil
      expect(link_to_file_url_with_name(file)).to eq nil
    end

    it 'should return nil if neither is available' do
      file = build :mod_file, download_url: nil, attachment: nil
      expect(link_to_file_url_with_name(file)).to eq nil
    end
  end
end
