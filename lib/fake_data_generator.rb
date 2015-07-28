class FakeDataGenerator
  def generate
    def gputs(val)
      puts val unless Rails.env.test?
    end
    ActiveRecord::Base.transaction do
      ### Categories, in case we run it on the test db
      ##################
      if Category.count == 0
        10.times do |i|
          Category.create! name: Forgery(:lorem_ipsum).words(1, random: true) + i.to_s
        end
      end

      ### Game
      ##################
      begin
        Game.create! name: Forgery(:lorem_ipsum).words(2, random: true)
      rescue Game::CannotCreateMoreThanOneGameError
      end
      game = Game.first


      ### Game Versions
      ##################
      gputs "---------- Creating game versions!"
      rand(3..4).times do |i|
        rand(4..6).times do |j|
          time_ago =  (4-i).months + (6-j).weeks
          game_version = GameVersion.create!(number: "#{i}.#{j}.x", released_at: Time.now - time_ago, game: game)
          gputs "Created game version #{game_version.number}"
        end
      end
      game_versions = GameVersion.all.sort_by_older_to_newer

      ### Users
      ##################
      gputs "---------- Creating users!"
      rand(5..10).times do |i|
        pass = Forgery(:basic).password(at_least: 8, at_most: 20)
        user = User.create!(email: Forgery(:internet).email_address + i.to_s,
                     name: Forgery(:internet).user_name + i.to_s,
                     password: pass,
                     password_confirmation: pass)
        gputs "Created user #{user.name} #{user.email}"
      end
      users = User.all

      ### Subforum
      ##################
      subforum = Subforum.create!(url: 'http://www.factorioforums.com/forum/viewforum.php?f=91')

      ### Forum posts
      ##################
      # Actually scrap the forum posts from the Factorio forum
      # in real time, I don't see why not, it's just a few pages.
      gputs "---------- Scraping real life forum posts! This make take a while..."
      scraper_manager = Scraper::SubforumManager.new [subforum]
      scraper_manager.run
      posts = subforum.forum_posts

      ### Mods
      ##################
      gputs "---------- Creating mods!"
      imgurs = ['b9VDd2E', '6TIfdyR', '6DS3LT6', 'jRBKTqv', '']

      categories = Category.all
      rand(30..50).times do |i|
        github_url = Forgery(:lorem_ipsum).words(1, random: true) + '/' + Forgery(:lorem_ipsum).words(1, random: true)
        mod = Mod.create! name: Forgery(:lorem_ipsum).words(rand(3..6), random: true),
                          info_json_name: Forgery(:lorem_ipsum).words(rand(1..2), random: true),
                          authors: users.sample(8),
                          owner: [nil, nil].concat(users).sample,
                          categories: categories.sample(rand(1..4)),
                          github: rand > 50 ? nil : github_url,
                          # license: ['MIT', 'GPLv2', 'GPLv3'].sample,
                          # license_url: ['https://tldrlegal.com/license/mit-license',
                          #               'https://tldrlegal.com/license/gnu-general-public-license-v2',
                          #               'https://tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3)'].sample,
                          official_url: rand > 75 ? nil : "http://" + Forgery(:internet).domain_name,
                          # favorites_count: rand(0..100),
                          forum_url: posts.sample.url, # This will associate them on save
                          # downloads_count: rand(0..25000),
                          # visits_count: rand(0..100000),
                          # description: Forgery(:lorem_ipsum).paragraphs(rand(3..6), random: true),
                          summary: Forgery(:lorem_ipsum).words(rand(10..100), random: true),
                          imgur: imgurs.sample

        mod_categories = mod.categories.map(&:name).join(', ')
        gputs "Created mod #{mod.name}, Categories: #{mod_categories}"
      end

      ### Mod Versions
      ##################
      gputs "---------- Creating mod versions and files!"
      Mod.all.each do |mod|
        mod.versions = rand(1..3).times.map do |i|
          ModVersion.new game_versions: game_versions[i..(rand(i..game_versions.size))],
                         number: i,
                         released_at: Time.now - (5-i).weeks


        end
        mod_versions = mod.versions.sort_by_older_to_newer

        ### Mod Files
        ##################
        mod_versions.each do |mod_version|
          mod_version.files = rand(1..2).times.map do |i|
            download = [1,2,3,4,5,6,7].sample
            ModFile.new name: rand > 0.05 ? nil : Forgery(:lorem_ipsum).words(1, random: true).downcase,
                        attachment: [1,2].include?(download) ? File.new(Rails.root.join('spec', 'fixtures', 'test.zip')) : nil,
                        download_url: [2,3,4,5,6,7].include?(download) ? "http://github.com/potato/mod/releases/whatever-#{1}.zip" : nil
          end
        end

        mod.save!
        gputs "Added #{mod_versions.size} versions to mod #{mod.name}"
      end
    end
  end
end
