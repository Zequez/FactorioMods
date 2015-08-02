describe Scraper::PostProcessor do
  def scrap(page_url)
    VCR.use_cassette('forum_post', record: :new_episodes) do
      @scraper = Scraper::Base.new page_url, Scraper::PostProcessor
      @result = @scraper.scrap
    end
  end

  describe 'URL detection' do
    it 'should detect forum posts pages URLs' do
      expect{ scrap('http://www.factorioforums.com/forum/viewtopic.php?f=93&t=14371') }.to_not raise_error
    end

    it 'should raise an error with a non-post URL' do
      expect{ scrap('http://www.factorioforums.com/forum/viewforum.php?f=83') }.to raise_error Scraper::NoPageProcessorFoundError
    end

    it 'should raise an error with pagination' do
      expect{ scrap('http://www.factorioforums.com/forum/viewtopic.php?f=43&t=6456&start=20') }.to raise_error Scraper::NoPageProcessorFoundError
    end
  end

  describe 'Post layouts detection' do
    describe 'pretty perfect template layout' do
      before(:all){ scrap 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=14294' }
      subject{ @result.first }

      its([:summary]) { is_expected.to eq '' }
      its([:title]) { is_expected.to eq 'Science Cost Tweaker Mod' }
      its([:mod_name]) { is_expected.to eq 'ScienceCostTweaker' }
      its([:description]) { is_expected.to eq 'This mod can be used as a simple alternative to marathon mod. It increases science costs significantly (4x to 9x depending on tier) - you need bigger factory to feed your science labs. Science also now has its own dedicated production lines and intermediate products. No more making science packs from conveyor belts and inserters!' }
      its([:game_version]) { is_expected.to eq ['0.12.x'] }
      its([:download_url]) { is_expected.to eq 'http://www.factorioforums.com/forum/download/file.php?id=4985' }
      its([:file_name]) { is_expected.to eq 'ScienceCostTweaker_0.12.4.zip' }
      its([:version]) { is_expected.to eq '0.12.4' }
      its([:last_release_at]) { is_expected.to be_within(1.hour).of DateTime.parse('July 30, 2015') }
      its([:license]) { is_expected.to eq 'GPL.' }
      its([:license_url]) { is_expected.to eq 'https://github.com/UberWaffe/ScienceCostTweaker/blob/master/LICENSE'}
      its([:github_url]) { is_expected.to eq 'https://github.com/UberWaffe/ScienceCostTweaker' }
      its([:authors]) { is_expected.to eq ['UberWaffe'] }
      its([:contact]) { is_expected.to eq 'https://github.com/UberWaffe/ScienceCostTweaker' }
      its([:last_edited_at]) { is_expected.to be_within(1.hour).of DateTime.parse('Jul 31, 2015 11:46 am') }
      its([:tags]) { is_expected.to eq ['Technology', 'Difficulty', 'Game Length'] }
    end

    # describe 'a layout with a non-standard info-list' do
    #   before(:all){ scrap 'http://www.factorioforums.com/forum/viewtopic.php?f=92&t=13937' }
    #   subject{ @result.first }
    #
    #   its([:summary]) { is_expected.to eq 'Show GUI messages, controlled via the circuit network.' }
    #   its([:title]) { is_expected.to eq 'Circuit GUI' }
    #   its([:mod_name]) { is_expected.to eq 'ScienceCostTweaker' }
    #   its([:description]) { is_expected.to eq '' }
    #   its([:game_version]) { is_expected.to eq ['0.12.x'] }
    #   its([:download_url]) { is_expected.to eq 'http://www.factorioforums.com/forum/download/file.php?id=4985' }
    #   its([:file_name]) { is_expected.to eq 'ScienceCostTweaker_0.12.4.zip' }
    #   its([:version]) { is_expected.to eq '0.12.4' }
    #   its([:last_release_at]) { is_expected.to be_within(1.hour).of DateTime.parse('July 30, 2015') }
    #   its([:license]) { is_expected.to eq 'GPL.' }
    #   its([:license_url]) { is_expected.to eq 'https://github.com/UberWaffe/ScienceCostTweaker/blob/master/LICENSE'}
    #   its([:github_url]) { is_expected.to eq 'https://github.com/UberWaffe/ScienceCostTweaker' }
    #   its([:authors]) { is_expected.to eq ['UberWaffe'] }
    #   its([:contact]) { is_expected.to eq 'https://github.com/UberWaffe/ScienceCostTweaker' }
    #   its([:last_edited_at]) { is_expected.to be_within(1.hour).of DateTime.parse('Jul 31, 2015 11:46 am') }
    #   its([:tags]) { is_expected.to eq ['Technology', 'Difficulty', 'Game Length'] }
    # end
  end
end
