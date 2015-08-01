describe Scraper::SubforumManager do
  manager_class = Scraper::SubforumManager
  scraper_class = Scraper::Base

  it 'should accept a collection of subforums as parameter' do
    create :subforum, url: 'http://www.factorioforums.com/forum/viewforum.php?f=32'
    create :subforum, url: 'http://www.factorioforums.com/forum/viewforum.php?f=33'
    create :subforum, url: 'http://www.factorioforums.com/forum/viewforum.php?f=34'

    expect{manager_class.new(Subforum.all)}.to_not raise_error
  end

  describe '#run' do
    def scraper_mock(scrap_result = nil)
      @scraper_mock ||= begin
        double = instance_double('ScraperClass')
        if scrap_result
          expect(double).to receive(:scrap).and_return(scrap_result)
        end
        double
      end
    end

    it 'should create a new instance of Scraper and call #scrap on it' do
      create :subforum, url: 'http://potato.com'
      create :subforum, url: 'http://cabbage.com'

      scraper_mock = instance_double('ScraperClass')
      expect(scraper_class).to receive(:new).with(['http://potato.com', 'http://cabbage.com']).and_return(scraper_mock)
      expect(scraper_mock).to receive(:scrap).and_return({
        'http://potato.com' => [],
        'http://cabbage.com' => []
      })

      manager = manager_class.new(Subforum.all)
      manager.run
    end

    it 'should update the #last_scrap_at on each Subforum' do
      subforum = create :subforum, last_scrap_at: 1.year.ago
      scraper_mock( subforum.url => [])
      expect(scraper_class).to receive(:new).and_return(scraper_mock)

      manager = manager_class.new([subforum])
      manager.run
      expect(subforum.last_scrap_at).to be > 1.minute.ago
      subforum.reload
      expect(subforum.last_scrap_at).to be > 1.minute.ago
    end

    context 'all the forum posts are new' do
      it 'should create the forum posts and add them to the database' do
        subforum = create :subforum
        scraper_mock(subforum.url => [{
          title: '[0.12.x] Super Mod - The Most Awesome Mod Ever',
          published_at: DateTime.parse('Sat Sep 20, 2014 12:04 am UTC'),
          last_post_at: DateTime.parse('Wed Jul 22, 2015 4:06 pm UTC'),
          views_count: 8463,
          comments_count: 123,
          author_name: 'Potato',
          url: 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4845',
          post_number: 4845
        }, {
          title: '[0.12.x] Potato Salad Mod',
          published_at: DateTime.parse('Sat Sep 24, 2014 12:04 am UTC'),
          last_post_at: DateTime.parse('Wed Jul 26, 2015 4:06 pm UTC'),
          views_count: 1234,
          comments_count: 5,
          author_name: 'Mike',
          url: 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4848',
          post_number: 4848
        }])
        expect(scraper_class).to receive(:new).and_return(scraper_mock)

        manager = manager_class.new(Subforum.all)
        manager.run
        all_posts = ForumPost.all
        expect(all_posts.size).to eq 2
        expect(all_posts[0].attributes.symbolize_keys).to include({
          title: '[0.12.x] Super Mod - The Most Awesome Mod Ever',
          published_at: DateTime.parse('Sat Sep 20, 2014 12:04 am UTC'),
          last_post_at: DateTime.parse('Wed Jul 22, 2015 4:06 pm UTC'),
          views_count: 8463,
          comments_count: 123,
          author_name: 'Potato',
          url: 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4845',
          post_number: 4845,
          subforum_id: subforum.id
        })
        expect(all_posts[1].attributes.symbolize_keys).to include({
          title: '[0.12.x] Potato Salad Mod',
          published_at: DateTime.parse('Sat Sep 24, 2014 12:04 am UTC'),
          last_post_at: DateTime.parse('Wed Jul 26, 2015 4:06 pm UTC'),
          views_count: 1234,
          comments_count: 5,
          author_name: 'Mike',
          url: 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4848',
          post_number: 4848,
          subforum_id: subforum.id
        })
      end
    end

    context 'some forum posts already exist' do
      it 'should update all the attributes' do
        subforum1 = create :subforum
        subforum2 = create :subforum
        forum_post = create(:forum_post, {
          title: '[0.12.x] Potato Salad Mod (0.1.0)',
          published_at: DateTime.parse('Sat Sep 24, 2014 12:04 am UTC'),
          last_post_at: DateTime.parse('Wed Jul 26, 2015 4:06 pm UTC'),
          views_count: 1234,
          comments_count: 5,
          author_name: 'Mike',
          url: 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4848',
          post_number: 4848,
          subforum_id: subforum1.id
        })

        scraper_mock(subforum2.url => [{
          title: '[0.12.x] Potato Salad Mod (0.1.1)',
          published_at: DateTime.parse('Sat Sep 24, 2014 12:04 am UTC'),
          last_post_at: DateTime.parse('Wed Jul 26, 2015 7:46 pm UTC'),
          views_count: 1444,
          comments_count: 12,
          author_name: 'Mike',
          url: 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4848',
          post_number: 4848
        }])
        expect(scraper_class).to receive(:new).and_return(scraper_mock)
        manager = manager_class.new([subforum2])
        manager.run

        expect(ForumPost.all.size).to eq 1
        forum_post.reload
        expect(forum_post.attributes.symbolize_keys).to include({
          title: '[0.12.x] Potato Salad Mod (0.1.1)',
          published_at: DateTime.parse('Sat Sep 24, 2014 12:04 am UTC'),
          last_post_at: DateTime.parse('Wed Jul 26, 2015 7:46 pm UTC'),
          views_count: 1444,
          comments_count: 12,
          author_name: 'Mike',
          url: 'http://www.factorioforums.com/forum/viewtopic.php?f=91&t=4848',
          post_number: 4848,
          subforum_id: subforum2.id
        })
      end
    end
  end
end