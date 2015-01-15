require 'net/http'
require 'nokogiri'

class ForumPostsScraper < Scraper::Base
  def scrap
    array = []
    while page = get_next_page
      ### UTC
      utc_string = page.doc.search('.navbar .linklist .rightside').text.match(/are\s*(.*)\s*(hours)?\s*$/)[1]
      utc_string.gsub!(' ', '')

      page.doc.search('.forumbg:not(.announcement) .row').each do |row|
        ### Post Number
        post_number = row.search('dt a[href^="./viewtopic"]').attribute('href').value.match(/t=([0-9]+)/)[1].to_i

        ### Find the post or create if it doesn't exist
        post = ForumPost.find_or_create_by(post_number: post_number)

        ### Title
        title = row.search('.topictitle').text
        post.title_changed = post.title != title if not post.title_changed
        post.title = title

        ### Published Date At
        date_string = row.search('dl dt').text.match(/»\s*(.+)\s*$/)[1]
        date_string += " #{utc_string}"
        post.published_at = DateTime.parse date_string

        ### Last Post At
        date_string = row.search('.lastpost span').text.match(/\s{2,}(.+)$/m)[1]
        date_string += " #{utc_string}"
        post.last_post_at = DateTime.parse date_string

        ### Views Count
        post.views_count = row.search('.views').text.to_i

        ### Comments Count
        post.comments_count = row.search('.posts').text.to_i

        ### Author Name
        post.author_name = row.search('dt a[href^="./memberlist"]').text.strip

        ### URL
        post.url = page_post post.post_number

        ### Edited At
        # TODO: Gotta check inside the post

        array.push post
      end
    end
    array
  end

  private

  def page_post(post_id)
    "http://www.factorioforums.com/forum/viewtopic.php?f=14&t=#{post_id}"
  end

  def page_base(page_number)
    page_number = page_number.kind_of?(String) ? page_number : page_number * 25
    "http://www.factorioforums.com/forum/viewforum.php?f=14&start=#{page_number}"
  end

  def next_page_url_from_dom(page)
    link = page.doc.search('.display-options .right-box.right').first
    if link
      number = link.attribute('href').value.match(/start=([0-9]+)/)[1]
      page_base number.to_s
    else
      nil
    end
  end
end