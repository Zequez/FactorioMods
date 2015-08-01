describe Scraper::BaseProcessor do
  it 'should initialize with 4 arguments' do
    doc = Nokogiri::HTML('<html></html>')
    request = Struct.new(:url).new('http://potato.com')
    response = Struct.new(:body).new('<html></html>')
    scraper = Scraper::Base.new('http://purple.com')
    initial_url = 'http://purple.com'

    Scraper::BaseProcessor.new(doc, request, response, scraper, initial_url)
  end

  describe '.regexp' do
    it 'should return a nonmatching regex by default' do
      expect(Scraper::BaseProcessor.regexp).to eq /(?!)/
    end

    it 'should save the regex when called with a value' do
      class ExtendedProcessor < Scraper::BaseProcessor
        regexp /potato/
      end
      expect(ExtendedProcessor.regexp).to eq /potato/
      expect(Scraper::BaseProcessor.regexp).to eq /(?!)/
    end
  end

  it 'should delegate :add_to_queue and :add_to_queue_unless_there to the scraper' do
    class ExtendedProcessor < Scraper::BaseProcessor
      def process_page
        add_to_queue('rsarsa')
        add_to_queue_unless_there('rsarsarsa')
      end
    end

    doc = Nokogiri::HTML('<html></html>')
    request = Struct.new(:url).new('http://purple.com/satrsat')
    response = Struct.new(:body).new('<html></html>')
    scraper = Scraper::Base.new('http://rsarsa.com')
    initial_url = 'http://purple.com'

    expect(scraper).to receive(:add_to_queue).with('rsarsa', 'http://purple.com')
    expect(scraper).to receive(:add_to_queue_unless_there).with('rsarsarsa', 'http://purple.com')

    processor = ExtendedProcessor.new(doc, request, response, scraper, initial_url)

    processor.process_page
  end
end