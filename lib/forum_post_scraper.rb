require 'net/http'
require 'nokogiri'

class ForumPostScraper < Scraper::Base

  def initialize(forum_post)
    @forum_post = forum_post
    super()
  end

  def scrap
    page = get_next_page

    @forum_post.content = page.doc.search('.content').first.children.to_s

    @forum_post
  end

  def page_base(number)
    @forum_post.url
  end

  def next_page_url_from_dom
    nil
  end
end