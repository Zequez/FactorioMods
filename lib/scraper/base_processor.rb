class Scraper::BaseProcessor
  def initialize(doc, request, response, scraper, initial_url)
    @data = nil
    @doc = doc
    @request = request
    @response = response
    @scraper = scraper
    @initial_url = initial_url
  end

  attr_accessor :data

  def process_page
  end

  def add_to_queue_unless_there(url)
    @scraper.add_to_queue_unless_there(url, @initial_url)
  end

  def add_to_queue(url)
    @scraper.add_to_queue(url, @initial_url)
  end

  def self.regexp(value = nil)
    (@regexp = value if value) || @regexp || /(?!)/
  end

  def self.addition_method(value = nil)
    (@addition_method = value if value) || @addition_method || :push
  end
end