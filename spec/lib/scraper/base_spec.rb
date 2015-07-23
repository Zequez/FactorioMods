require 'rails_helper'

describe Scraper::Base do
  before(:all) do
    @previous_processors = Scraper::Base.class_variable_get :@@processors
  end
  after(:each) do
    Scraper::Base.class_variable_set :@@processors, []
  end
  after(:all) do
    Scraper::Base.class_variable_set :@@processors, @previous_processors
  end

  describe '.register_processor' do
    it 'should be able to register a processor' do
      expect{Scraper::Base.register_processor(Scraper::BaseProcessor)}.to_not raise_error
    end

    it 'should raise an error if trying to register an invalid processor' do
      expect{Scraper::Base.register_processor('potato')}.to raise_error Scraper::InvalidProcessorError
    end
  end

  describe '#scrap', vcr: { cassette_name: 'scraper_base', record: :new_episodes } do
    it 'should raise a NoPageProcessorFoundError error if no processor was found for the page' do
      scraper = Scraper::Base.new('http://www.purple.com')
      expect{scraper.scrap}.to raise_error Scraper::NoPageProcessorFoundError
    end

    it 'should process each page and return an array of the processed data' do
      class ExtendedProcessor < Scraper::BaseProcessor
        regexp %r{http://www\.purple\.com}
        Scraper::Base.register_processor(self)

        def process_page
          'Yeaaaah!'
        end
      end

      scraper = Scraper::Base.new('http://www.purple.com')
      expect(scraper.scrap).to eq ['Yeaaaah!']
    end

    it 'should process each page and return concatenation of the arrays of the processed data' do
      class ExtendedProcessor < Scraper::BaseProcessor
        regexp %r{http://www\.purple\.com}
        addition_method :concat
        Scraper::Base.register_processor(self)

        def process_page
          ['Yeaaaah!', 'Potato!']
        end
      end

      scraper = Scraper::Base.new('http://www.purple.com')
      expect(scraper.scrap).to eq ['Yeaaaah!', 'Potato!']
    end

    it 'should return a hash with the URLs if multiple URLs were provided' do
      class ExtendedProcessor1 < Scraper::BaseProcessor
        regexp %r{http://www\.purple\.com}
        Scraper::Base.register_processor(self)

        def process_page
          'Purple is the best!'
        end
      end

      class ExtendedProcessor2 < Scraper::BaseProcessor
        regexp %r{http://www\.zombo\.com}
        Scraper::Base.register_processor(self)

        def process_page
          'Welcome to Zombocom!'
        end
      end

      scraper = Scraper::Base.new(['http://www.zombo.com', 'http://www.purple.com'])
      expect(scraper.scrap).to eq({
        'http://www.zombo.com' => ['Welcome to Zombocom!'],
        'http://www.purple.com' => ['Purple is the best!']
      })
    end
  end
end