class Imgur
  attr_accessor :url
  attr_reader :string, :id, :thumbnail_id, :is_album, :extension, :thumbnail_url, :canonical_url, :valid
  alias_method :to_s, :string
  alias_method :to_string, :string
  alias_method :valid?, :valid

  IMGUR_IMAGE_URLS = [
    %r{\Ahttps?://imgur\.com/(\w+)\Z},
    %r{\Ahttps?://i\.imgur\.com/(\w+)\.(\w+)\Z}
  ]

  IMGUR_ALBUM_URLS = [
    %r{\Ahttps?://imgur\.com/a/(\w+)\Z},
    %r{\Ahttps?://imgur\.com/gallery/(\w+)\Z}
  ]

  def url=(val)
    @url = val
    clean
    parse_url
    @url
  end

  def parse_url
    if @url
      match = nil
      if (match = get_album_match)
        @is_album = true
        @id = match[1]
        @extension = nil
        @canonical_url = generate_canonical_url
      elsif (match = get_image_match)
        @is_album = false
        @id = match[1]
        @thumbnail_id = match[1]
        @thumbnail_url = generate_thumbnail_url
        @canonical_url = generate_canonical_url
      end

      if match && (image_url = request_canonical_page_image_url)
        match = get_image_match(image_url)

        if @is_album
          @thumbnail_id = match[1]
          @thumbnail_url = generate_thumbnail_url
        else
          @extension = match[2]
        end

        @string = generate_string
        @valid = true
      else
        clean
        @valid = false
      end
    else
      @valid = true
    end
  end

  ### Serialization for ActiveRecord

  def self.dump(imgur)
     raise ::ActiveRecord::SerializationTypeMismatch unless imgur.is_a?(self)
     imgur.to_s
  end

  def self.load(val)

  end

  ### Private land

  private

  def request_canonical_page_image_url
    response = Net::HTTP.get_response(URI(@canonical_url))
    if response.code == '200'
      doc = Nokogiri::HTML response.body

      image_src = doc.css('link[rel="image_src"]').first

      if image_src
        image_src.attribute('href').value
      else
        nil
      end
    else
      nil
    end
  end

  def get_image_match(url = @url)
    match = nil
    IMGUR_IMAGE_URLS.any? {|reg| match = reg.match(url) }
    match
  end

  def get_album_match
    match = nil
    IMGUR_ALBUM_URLS.any? {|reg| match = reg.match(@url) }
    match
  end

  def generate_canonical_url
    album = @is_album ? 'a/' : ''
    "http://imgur.com/#{album}#{id}"
  end

  def generate_thumbnail_url
    "http://i.imgur.com/#{@thumbnail_id}s.jpg"
  end

  def generate_string
    "#{@id}.#{@extension} #{@thumbnail_id}"
  end

  def clean
    @string = nil
    @id = nil
    @thumbnail_id = nil
    @is_album = nil
    @extension = nil
    @thumbnail_url = nil
  end
end