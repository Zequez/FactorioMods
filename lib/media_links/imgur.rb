module MediaLinks
  class Imgur < Base
    def self.match?(url)
      url = base_url(url)
      return true if url =~ %r{\Ahttps?://i.imgur\.com/\w+\.\w+\Z}
      return true if url =~ %r{\Ahttps?://imgur\.com/gallery/\w+\Z}
      return true if url =~ %r{\Ahttps?://imgur\.com/r/\w+/\w+\Z}
      return true if url =~ %r{\Ahttps?://imgur\.com/\w+\Z}
      false
    end

    def embed
      tag :img, src: direct_url, class: ['media-link', 'media-link-imgur']
    end

    def canonical_url
      "http://imgur.com/gallery/#{key}"
    end

    def direct_url
      "http://i.imgur.com/#{key}.jpg"
    end

    def thumbnail_url
      "http://i.imgur.com/#{key}s.jpg"
    end

    def key
      @key ||= base_url.match(%r{/(\w+)(\.\w+)?\Z})[1]
    end
  end
end