module Scraper
  class PostProcessor < Scraper::BaseProcessor
    regexp %r{\Ahttps?://(www\.)?factorioforums.com/forum/viewtopic\.php\?f=[0-9]+&t=[0-9]+(&start=0)?\Z}

    def process_page
      post = {}
      c = @doc.search('.content').first

      urls = c.to_s.scan(%r{href="([^"]+)"}).flatten.map

      # Github URL
      if ( github = urls.detect{|url| url.match('github.com')} )
        post[:github_url] =  github.gsub(%r{(github.com/[^/]+/[^/]+).*}, '\1')
      else
        post[:github_url] = nil
      end

      # Download URLs
      if ( download_url = urls.detect{|url| url.match('download/file.php')} )
        request_uri = URI.parse(@request.url)
        base_path = request_uri.scheme + '://' + request_uri.host + request_uri.path.sub(/[^\/]+$/, '')
        download_url = download_url.gsub(%r{&amp;sid=[0-9a-z]+}i, '').gsub(/^.\//, base_path)
        post[:download_url] = download_url
      else
        post[:download_url] = nil
      end

      # Summary
      summary = c.search('ul').first.children.take_while{|node| node.name != 'li'}.map(&:text).join.strip
      post[:summary] = summary

      # Title
      title = @doc.search('#page-body h2').first.text
      post[:title] = title = title.gsub(/\[[^\]]+\]/, '').gsub(/\([^)]+\)/, '').strip

      # Last edit time
      last_edited_at = @doc.search('.postbody .notice').to_s.match(/(?<=<\/a> on ).+?(am|pm)/)
      if last_edited_at
        post[:last_edited_at] = last_edited_at = DateTime.parse last_edited_at.to_s
      end

      # Long Description
      description = c.text.match(/Long Description:?(.*?)(?:Bugs|$)/)
      if description
        post[:description] = description[1]
      end

      ### Parsing the info list
      #########################

      @info = info = []
      c.search('ul').first.search('li').each do |li|
        splitted = li.text.split(':')
        info.push(
          key: splitted.shift.strip,
          value: splitted.join(':').strip,
          html: li
        )
      end

      # Extract file name, mod name, and mod version
      if ( file_name = match_info(/\.zip$/, :value) )
        if ( file_name = file_name[:value].match(/[^\s]+[_-][0-9\.]+\.zip/) )
          post[:file_name] = file_name = file_name.to_s
          mod_version = file_name.match(/[_-]([0-9\.]+)\.zip/)
          if mod_version
            post[:version] = mod_version = mod_version[1]
            mod_name = file_name.match(/^(.*?)[_-]\d/)
            if mod_name
              post[:mod_name] = mod_name = mod_name[1]
            end
          end
        end
      else

      end

      # Extract tags/categories
      if ( tags = match_info(/tags?|categories|category/i) )
        post[:tags] = tags[:value].split(',').map(&:strip)
      end

      # Extract contact info
      if ( contact = match_info(/Contact/) )
        if ( contact_url = URI.extract(contact[:html].to_s).detect{|url| url =~ /^http/} )
          post[:contact] = contact_url
        else
          post[:contact] = contact[:value].strip
        end
      end

      # Extract author/authors
      if ( authors = match_info(/authors?/i) )
        post[:authors] = authors[:value].split(',').map(&:strip)
      end

      # Extract license
      if ( license = match_info(/license/i) )
        post[:license] = license[:value]
        urls = extract_urls(license[:html])
        unless urls.empty?
          post[:license_url] = urls.first
        end
      end

      # Extract game version
      if ( game_version = match_info(/factorio/i) )
        post[:game_version] = game_version[:value].split(/[-,]/).map(&:strip)
      end

      # Extract last release version
      if ( row = match_info(/latest release|last release/i) )
        if ( date = row[:value].match(/(?<=,).*/) )
          post[:last_release_at] = date = DateTime.parse(date.to_s)
        end
      end

      post
    end

    private

    def match_info(regex, type = :key)
      @info.detect{|pair| pair[type].match(regex) }
    end

    def extract_urls(text)
      URI.extract(text.to_s).select{|url| url =~ /^http/}
    end
  end
end
