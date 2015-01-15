require 'json'

module MediaLinks
  class Manager < Array
    @@types = [Imgur, Gfycat]

    attr_reader :media_links, :invalid_urls, :valid_urls

    def initialize(media_links_string_or_array)
      @media_links = self
      @valid_urls = []
      @invalid_urls = []

      if media_links_string_or_array.kind_of? Array
        parse_array_links(media_links_string_or_array)
      else
        parse_string_links(media_links_string_or_array)
      end
    end

    def valid?
      @invalid_urls.size == 0
    end

    def to_string
      media_links.map{|ml| ml.canonical_url}.join("\n")
    end

    def to_array
      media_links.inject([]) do |array, ml|
        name = ml.class.name.split('::').last
        array.push [name, ml.key]
        array
      end
    end

    def self.dump(manager)
      raise ::ActiveRecord::SerializationTypeMismatch unless manager.is_a?(self)
      JSON.dump(manager.to_array)
    end

    def self.load(dumped_array)
      media_links_array = JSON.load(dumped_array)
      self.new media_links_array
    end

    private 

    def parse_array_links(array)
      array.each do |arr|
        klass_name = arr[0]
        key = arr[1]
        klass = @@types.find{|klass| klass.last_name == klass_name}
        @media_links.push klass.new(nil, key) 
      end
    end

    def parse_string_links(string)
      media_links_array = string.to_s.strip.split(/\s+/)
      media_links_array.map do |url|
        klass = @@types.find{|klass| klass.match? url}
        if klass
          @media_links.push klass.new(url)
          @valid_urls.push url
        else
          @invalid_urls.push url
        end
      end
    end
  end
end