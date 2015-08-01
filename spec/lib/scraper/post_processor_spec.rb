describe Scraper::PostProcessor, vcr: { cassette_name: 'forum_post', record: :new_episodes } do
  def scrap(page_url)
    @scraper = Scraper::Base.new page_url, Scraper::SubforumProcessor
    @result = @scraper.scrap
  end

  # describe 'URL detection' do
  #   it 'should detect forum posts pages'
  # end
end
