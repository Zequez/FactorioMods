module MediaLinks
  class Base
    include ActionView::Helpers::TagHelper

    def initialize(url = nil, key = nil)
      @url = url
      @key = key
    end

    def self.match?(url)
      raise 'Not implemented'
    end

    def self.last_name
      @last_name ||= name.split('::').last
    end

    def self.base_url(url)
      url.gsub(/\?.*\Z/, '')
    end

    def embed
      raise 'Not implemented'
    end

    def to_string
      canonical_url
    end

    def base_url
      @base_url ||= @url.gsub(/\?.*\Z/, '')
    end

    def canonical_url
      raise 'Not implemented'
    end

    def direct_url
      raise 'Not implemented'
    end

    def thumbnail_url
      raise 'Not implemented'
    end

    def key
      raise 'Not implemented'
    end
  end
end