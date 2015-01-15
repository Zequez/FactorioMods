module Scraper
  class Base
    def initialize
      @current_page_number = -1
      @current_page = nil
    end

    def page_base(page_number)
      ''
    end

    def get_next_page
      url = next_page_url(@current_page)
      @last_page = @current_page
      if url
        page = Page.new(url)
        @current_page = page.is_end_page? ? nil : page
      else
        @current_page = nil
      end
    end

    def next_page_url(page = nil)
      if page
        next_page_url_from_dom(page)
        # Find it in the DOM
      else
        next_page_url_from_number
      end
    end

    def next_page_url_from_number
      page_base @current_page_number+1
    end

    def next_page_url_from_dom(current_page)
      false
    end
  end
end