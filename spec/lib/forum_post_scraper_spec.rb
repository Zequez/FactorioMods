require 'rails_helper'

describe ForumPostScraper do
  def fixture(name)
    file_name = File.expand_path("../../fixtures/forum_post/#{name}.html", __FILE__)
    File.read file_name
  end

  def stub_page(url, name)
    web_content = fixture name
    stub_request(:get, url).to_return body: web_content
  end

  it 'should return the forum post filled with a "content" parameter' do
    forum_post = create :forum_post
    stub_page forum_post.url, 'basic_post'
    scraper = ForumPostScraper.new forum_post
    forum_post = scraper.scrap
    # Very fragile to match the exact HTML Nokogiri outputs, but whatever
    expect(forum_post.content).to eq "<h3>Hey there</h3>\n<strong>I'm here to kill you!</strong><ul>\n<li>And a list of stuff!</li>\n<li>And more stuff!</li>\n</ul>"
  end
end