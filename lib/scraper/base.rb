require 'typhoeus'
require 'nokogiri'

module Scraper
  class Base
    attr_reader :data

    def initialize(initial_url, processors)
      @processors = Array(processors)
      @initial_urls = Array(initial_url)
      @multi_urls = initial_url.kind_of? Array
      @hydra = Typhoeus::Hydra.hydra
      @urls_queued = []
    end

    def scrap
      @data = {}
      @initial_urls.each do |initial_url|
        @data[initial_url] = []
        add_to_queue initial_url, initial_url
      end
      @hydra.run

      @multi_urls ? @data : @data.values.first
    end

    def process_page(doc, request, response)
    end

    def process_response(response, initial_url)
      document = Nokogiri::HTML(response.body)
      processor_class = @processors.detect{ |pc| pc.regexp.match response.request.url }
      if processor_class
        processor = processor_class.new(document, response.request, response, self, initial_url)
        @data[initial_url].method(processor_class.addition_method).call processor.process_page
      else
        available_processors_names = @processors.map{|p|p.class.name}.join(', ')
        raise NoPageProcessorFoundError.new("Available processors: #{available_processors_names}")
      end
    end

    def add_to_queue(url, initial_url)
      request = Typhoeus::Request.new(url)
      request.on_complete do |response|
        process_response response, initial_url
      end
      @urls_queued << url
      @hydra.queue request
    end

    # Queue the URL unless we already queued it before
    def add_to_queue_unless_there(url, initial_url)
      unless @urls_queued.include? url
        add_to_queue(url, initial_url)
      end
    end
  end
end
