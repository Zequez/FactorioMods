module Scraper
  class NoServerConnection < StandardError; end
  class InvalidGame < StandardError; end
  class InvalidReview < StandardError; end
  class TooManyRedirects < StandardError; end
  class UnexpectedResponse < StandardError; end
  class UnexpectedURI < StandardError; end
end