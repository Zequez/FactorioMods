module MediaLinks
  class Gfycat < Base
    def self.match?(url)
      return true if url =~ %r{\Ahttps?://gfycat\.com/\w+\Z}
      false
    end

    def embed
      content_tag(:iframe, '', src: direct_url, class: ['media-link', 'media-link-gfycat'])
    end

    def canonical_url
      "http://gfycat.com/#{key}"
    end

    def direct_url
      "http://gfycat.com/ifr/#{key}"
    end

    def thumbnail_url
      "https://thumbs.gfycat.com/#{key}-poster.jpg"
    end

    def key
      @key ||= @url.match(%r{/(\w+)\Z})[1]
    end
  end
end