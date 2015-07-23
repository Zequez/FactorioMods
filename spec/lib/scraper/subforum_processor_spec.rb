require 'rails_helper'

describe Scraper::SubforumProcessor do
  single_page = 'http://www.factorioforums.com/forum/viewforum.php?f=91'
  multiple_pages = 'http://www.factorioforums.com/forum/viewforum.php?f=32'

  it 'should accept a subforum URL as the first argument' do
    expect{ Scraper::Base.new 'http://potato.com' }.to_not raise_error
  end

  describe '#scrap' do
    it { expect(Scraper::Base.new('http://potato.com')).to respond_to :scrap }

    context 'single page' do
      before(:all) do
        VCR.use_cassette(cassette_name: 'subforum_single_page', record: :new_episodes) do
          @scraper = Scraper::Base.new single_page
          @result = @scraper.scrap
        end
      end

      subject(:result){ @result }

      it 'should return a list with the posts' do
        expect(@result.size).to eq 12
      end

      describe 'first post' do
        subject(:post){ @result.first }

        its(:keys) { are_expected.to eq [:title, :published_at, :last_post_at, :views_count,
                                        :comments_count, :author_name, :url, :post_number] }

        its([:title])          { is_expected.to eq '[MOD 0.12.x] Larger Inventory' }
        its([:published_at])   { is_expected.to eq DateTime.parse('Sat Sep 20, 2014 12:04 am UTC') }
        its([:last_post_at])   { is_expected.to eq DateTime.parse('Wed Jul 22, 2015 4:06 pm UTC') }
        its([:views_count])    { are_expected.to eq 8463 }
        its([:comments_count]) { are_expected.to eq 20 }
        its([:author_name])    { is_expected.to eq 'Rseding91' }
        its([:url])            { is_expected.to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=5891' }
        its([:post_number])    { is_expected.to eq 5891 }
      end

      describe 'middle post' do
        subject(:post){ @result[7] }
        its(:keys) { are_expected.to eq [:title, :published_at, :last_post_at, :views_count,
                                        :comments_count, :author_name, :url, :post_number] }

        its([:title])          { is_expected.to eq '[MOD 0.12.x] Compression Chests: virtually unlimited storage' }
        its([:published_at])   { is_expected.to eq DateTime.parse('Mon Jul 14, 2014 11:02 pm UTC') }
        its([:last_post_at])   { is_expected.to eq DateTime.parse('Sat Jul 18, 2015 1:44 pm UTC') }
        its([:views_count])    { are_expected.to eq 9987 }
        its([:comments_count]) { are_expected.to eq 50 }
        its([:author_name])    { is_expected.to eq 'Rseding91' }
        its([:url])            { is_expected.to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4845' }
        its([:post_number])    { is_expected.to eq 4845 }
      end

      describe 'last post' do
        subject(:post){ @result.last }
        its(:keys) { are_expected.to eq [:title, :published_at, :last_post_at, :views_count,
                                        :comments_count, :author_name, :url, :post_number] }

        its([:title])          { is_expected.to eq '[MOD 0.12.x] Fluid Void' }
        its([:published_at])   { is_expected.to eq DateTime.parse('Sun Aug 17, 2014 5:00 am UTC') }
        its([:last_post_at])   { is_expected.to eq DateTime.parse('Sun Dec 21, 2014 1:18 am UTC') }
        its([:views_count])    { are_expected.to eq 8377 }
        its([:comments_count]) { are_expected.to eq 16 }
        its([:author_name])    { is_expected.to eq 'Rseding91' }
        its([:url])            { is_expected.to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=5412' }
        its([:post_number])    { is_expected.to eq 5412 }
      end
    end

    context 'multiple pages' do
      before(:all) do
        VCR.use_cassette(cassette_name: 'subforum_multiple_pages', record: :new_episodes) do
          @scraper = Scraper::Base.new multiple_pages
          @result = @scraper.scrap
        end
      end

      subject(:result){ @result }

      it 'should return a list with the posts in all the pages' do
        expect(@result.size).to eq 97
      end

      describe 'first post of the first page' do
        subject(:post){ @result.first }

        its(:keys) { are_expected.to eq [:title, :published_at, :last_post_at, :views_count,
                                        :comments_count, :author_name, :url, :post_number] }

        its([:title])          { is_expected.to eq 'BlueprintMirror 0.0.3 [0.11.16+]' }
        its([:published_at])   { is_expected.to eq DateTime.parse('Tue Mar 24, 2015 4:09 pm UTC') }
        its([:last_post_at])   { is_expected.to eq DateTime.parse('Tue Jul 21, 2015 1:35 pm UTC') }
        its([:views_count])    { are_expected.to eq 1322 }
        its([:comments_count]) { are_expected.to eq 16 }
        its([:author_name])    { is_expected.to eq 'Choumiko' }
        its([:url])            { is_expected.to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=32&t=9273' }
        its([:post_number])    { is_expected.to eq 9273 }
      end

      describe 'fifth post of third page' do
        subject(:post){ @result[25+25+5-1] }

        its(:keys) { are_expected.to eq [:title, :published_at, :last_post_at, :views_count,
                                        :comments_count, :author_name, :url, :post_number] }

        its([:title])          { is_expected.to eq '[MOD WIP 0.9.x] EndlessWaltz - Enemy spawning mod like in TD' }
        its([:published_at])   { is_expected.to eq DateTime.parse('Sun Jun 01, 2014 6:43 pm UTC') }
        its([:last_post_at])   { is_expected.to eq DateTime.parse('Sat Nov 15, 2014 3:59 am UTC') }
        its([:views_count])    { are_expected.to eq 2189 }
        its([:comments_count]) { are_expected.to eq 7 }
        its([:author_name])    { is_expected.to eq 'blah900' }
        its([:url])            { is_expected.to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=32&t=4011' }
        its([:post_number])    { is_expected.to eq 4011 }
      end

      describe 'last post of last page' do
        subject(:post){ @result.last }

        its(:keys) { are_expected.to eq [:title, :published_at, :last_post_at, :views_count,
                                        :comments_count, :author_name, :url, :post_number] }

        its([:title])          { is_expected.to eq '[WIP] Radar Mod' }
        its([:published_at])   { is_expected.to eq DateTime.parse('Mon Feb 18, 2013 2:23 pm UTC') }
        its([:last_post_at])   { is_expected.to eq DateTime.parse('Wed Feb 20, 2013 2:02 am') }
        its([:views_count])    { are_expected.to eq 1453 }
        its([:comments_count]) { are_expected.to eq 5 }
        its([:author_name])    { is_expected.to eq 'kalapixie' }
        its([:url])            { is_expected.to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=32&t=156' }
        its([:post_number])    { is_expected.to eq 156 }
      end
    end
  end
end