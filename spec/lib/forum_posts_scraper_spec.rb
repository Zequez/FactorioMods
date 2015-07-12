require 'rails_helper'

describe ForumPostsScraper do
  subject(:scraper){ ForumPostsScraper.new }

  def fixture(name)
    file_name = File.expand_path("../../fixtures/forum_pages/#{name}.html", __FILE__)
    File.read file_name
  end

  def stub_page(url, name)
    web_content = fixture name
    stub_request(:get, url).to_return body: web_content
  end

  def stub_forum_page(number)
    from = (number-1)*25
    stub_page "http://www.factorioforums.com/forum/viewforum.php?f=87&start=#{from}", "page_#{number}"
  end

  it 'should be created without any argument' do
    expect{scraper}.to_not raise_error
  end

  describe '#scrap' do
    before :each do
      stub_forum_page 1
      stub_forum_page 2
      stub_forum_page 3
      stub_forum_page 4
      stub_forum_page 5
    end

    it 'should return a list' do
      expect(scraper.scrap.size).to eq 101
    end

    it 'should return forum posts with the correct #titles' do
      scraper.scrap.map { |post| expect(post).to be_kind_of ForumPost }
    end

    it 'should return forum posts with the correct #titles' do
      posts = scraper.scrap
      expect(posts[0].title).to eq '[MOD 0.10.x] Trailer Mod'
      expect(posts[1].title).to eq '[0.10.4+] Bumpers'
      expect(posts[2].title).to eq "[0.10.x] Bob's Ore Mod."
      expect(posts[3].title).to eq '[MOD 0.10.x] Tanks'
      expect(posts[4].title).to eq '[MOD 0.10.2] Automatic Rail Laying Machine'
    end

    it 'should return the forum posts with the correct #published_at' do
      posts = scraper.scrap
      expect(posts[0].published_at).to eq DateTime.parse 'Thu Jun 12, 2014 5:40 am UTC-3'
      expect(posts[1].published_at).to eq DateTime.parse 'Sat Aug 02, 2014 11:24 am UTC-3'
      expect(posts[2].published_at).to eq DateTime.parse 'Thu May 22, 2014 9:05 am UTC-3'
      expect(posts[3].published_at).to eq DateTime.parse 'Sun Aug 10, 2014 4:40 pm UTC-3'
      expect(posts[4].published_at).to eq DateTime.parse 'Fri Jun 13, 2014 1:03 am UTC-3'
    end

    it 'should return the forum posts with the correct #last_post_at' do
      posts = scraper.scrap
      expect(posts[0].last_post_at).to eq DateTime.parse 'Sun Jul 13, 2014 5:10 pm UTC-3'
      expect(posts[1].last_post_at).to eq DateTime.parse 'Mon Aug 11, 2014 1:16 pm UTC-3'
      expect(posts[2].last_post_at).to eq DateTime.parse 'Sun Aug 10, 2014 11:23 pm UTC-3'
      expect(posts[3].last_post_at).to eq DateTime.parse 'Sun Aug 10, 2014 5:11 pm UTC-3'
      expect(posts[4].last_post_at).to eq DateTime.parse 'Sun Aug 10, 2014 11:01 am UTC-3'
    end

    it 'should return the number of #views_count' do
      posts = scraper.scrap
      expect(posts[0].views_count).to eq 4292
      expect(posts[1].views_count).to eq 1034
      expect(posts[2].views_count).to eq 7327
      expect(posts[3].views_count).to eq 166
      expect(posts[4].views_count).to eq 4905
    end

    it 'should return the number of #comments_count' do
      posts = scraper.scrap
      expect(posts[0].comments_count).to eq 9
      expect(posts[1].comments_count).to eq 10
      expect(posts[2].comments_count).to eq 100
      expect(posts[3].comments_count).to eq 2
      expect(posts[4].comments_count).to eq 42
    end

    it 'should return the #author_name' do
      posts = scraper.scrap
      expect(posts[0].author_name).to eq 'slpwnd'
      expect(posts[1].author_name).to eq 'Schmendrick'
      expect(posts[2].author_name).to eq 'bobingabout'
      expect(posts[3].author_name).to eq 'SkaceKachna'
      expect(posts[4].author_name).to eq 'kolli'
    end

    it 'should return the post #url' do
      posts = scraper.scrap
      expect(posts[0].url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=4273'
      expect(posts[1].url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5127'
      expect(posts[2].url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=3797'
      expect(posts[3].url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5299'
      expect(posts[4].url).to eq 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=4287'
    end

    it 'should return the #post_number' do
      posts = scraper.scrap
      expect(posts[0].post_number).to eq 4273
      expect(posts[1].post_number).to eq 5127
      expect(posts[2].post_number).to eq 3797
      expect(posts[3].post_number).to eq 5299
      expect(posts[4].post_number).to eq 4287
    end

    # context 'live testing' do
    #   before(:each){ WebMock.disable! }
    #   after(:each){ WebMock.enable! }

    #   it 'should work' do
    #     posts = scraper.scrap
    #     posts.each(&:save!)
    #   end
    # end

    context 'posts already exist' do
      it 'identifies them from the #post_number and returns them updated' do
        post1 = create :forum_post, post_number: 4273
        post2 = create :forum_post, post_number: 5127
        post3 = create :forum_post, post_number: 3797

        posts = scraper.scrap
        expect(posts[0]).to eq post1
        expect(posts[1]).to eq post2
        expect(posts[2]).to eq post3
      end

      context 'title has changed' do

        it 'should set #title_changed to true' do
          post1 = create :forum_post, post_number: 4273, title: 'PTARTASRTRASTASRTSRAT', title_changed: false
          post2 = create :forum_post, post_number: 5127, title: '[0.10.4+] Bumpers', title_changed: false

          posts = scraper.scrap
          expect(posts[0].title_changed).to eq true
          expect(posts[1].title_changed).to eq false
        end
      end
    end
  end
end