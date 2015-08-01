module Scraper
  class SubforumProcessor < Scraper::BaseProcessor
    addition_method :concat
    regexp %r{\Ahttps?://(www\.)?factorioforums.com/forum/viewforum\.php\?f=[0-9]+(&start=[0-9]+)?\Z}

    def process_page
      posts = []
      ### UTC timezone
      utc_string = @doc.search('.navbar .linklist .rightside').text.match(/are\s*(.*)\s*(hours)?\s*$/)[1]
      utc_string.gsub!(' ', '')

      @doc.search('.topiclist.topics .row:not(.sticky)').each do |row|
        post = {}

        ### Title
        post[:title] = row.search('.topictitle').text

        ### Published Date At
        date_string = row.search('dl dt').text.match(/»\s*(.+)\s*$/)[1]
        post[:published_at] = DateTime.parse(date_string + " #{utc_string}")

        ### Last Post At
        date_string = row.search('.lastpost span').text.match(/\s{2,}(.+)$/m)[1]
        post[:last_post_at] = DateTime.parse(date_string + " #{utc_string}")

        ### Views Count
        post[:views_count] = row.search('.views').text.to_i

        ### Comments Count
        post[:comments_count] = row.search('.posts').text.to_i

        ### Author Name
        post[:author_name] = row.search('dt a[href^="./memberlist"]').text.strip

        ### URL
        post[:url] = link_url row.search('.topictitle')

        ### Post number
        post[:post_number] = URI::decode_www_form(URI(post[:url]).query).to_h['t'].to_i

        posts << post
      end

      ### Subforum pages
      @doc.search('.pagination').first.search('span a').each do |a|
        add_to_queue_unless_there link_url(a)
      end

      posts
    end

    private

    # Extract the URL from the HREF of a link, and
    # returns it as an absolute path
    def link_url(a)
      parse_url a.attribute('href').value
    end

    # We remove the session ID appended to the URL
    # And then we return the absolute URL
    def parse_url(relative_url)
      URI.join(@request.url, relative_url.gsub(/&sid=[^&]+/, '')).to_s
    end
  end
end
