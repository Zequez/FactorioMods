require 'scraper/subforum_processor'

module Scraper
  class NoPageProcessorFoundError < StandardError; end
  class InvalidProcessorError < StandardError; end
end