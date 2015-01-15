module Scraper
  class Page
    attr_reader :response
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def uri
      @uri ||= URI url
    end

    def raw
      @raw ||= get_page
    end

    def doc
      @doc ||= (raw == -1) ? nil : Nokogiri::HTML(raw)
    end

    def add_cookies(name, value)
      @cookies ||= []
      @cookies.push [name, value]
    end

    def is_end_page?
      false
    end

    private

    def get_page(redirects_limit = 10, retries_limit = 10)
      raise TooManyRedirects if redirects_limit == 0
      raise NoServerConnection if retries_limit == 0

      begin
        uri = URI url
        raise UnexpectedURI unless uri.respond_to?(:request_uri)
        request = Net::HTTP::Get.new(uri)

        request.add_field 'Cookie', @cookies.map{|a|a.join('=')}.join('; ') unless @cookies.blank?

        response = Net::HTTP.new(uri.host, uri.port).start do |http|
          http.request(request)
        end
      rescue Errno::ETIMEDOUT, Timeout::Error => e
        seconds = 10 + (10 - retries_limit)*3
        sleep seconds unless Rails.env.test?
        return get_page(url, redirects_limit, retries_limit - 1)
      end

      @response = response

      case response
      when Net::HTTPSuccess then response.body
      when Net::HTTPRedirection then
        # TODO: Think of something better
        if response['location'] =~ /\/app\//
          get_page(response['location'], redirects_limit - 1, retries_limit)
        else
          return -1
        end
      else
        raise UnexpectedResponse
      end
    end
  end
end