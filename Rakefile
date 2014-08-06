# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'Create fake data'
task fake_data: :environment do
  ActiveRecord::Base.transaction do
    ### Game
    ##################
    begin
      Game.create! name: Forgery(:lorem_ipsum).words(2, random: true)
    rescue Game::CannotCreateMoreThanOneGameError
    end
    game = Game.first


    ### Game Versions
    ##################
    rand(3..4).times do |i|
      rand(4..6).times do |j|
        time_ago =  (4-i).months + (6-j).weeks
        GameVersion.create!(number: "#{i}.#{j}.x", released_at: Time.now - time_ago, game: game)
      end
    end
    game_versions = GameVersion.all.sort_by_older_to_newer

    ### Users
    ##################
    rand(5..10).times do |i|
      pass = Forgery(:basic).password(at_least: 8, at_most: 20)
      User.create!(email: Forgery(:internet).email_address,
                   name: Forgery(:internet).user_name,
                   password: pass,
                   password_confirmation: pass)
    end
    users = User.all

    ### Mods
    ##################
    categories = Category.all
    rand(30..50).times do |i|
      github_url = Forgery(:lorem_ipsum).words(1, random: true) + '/' + Forgery(:lorem_ipsum).words(1, random: true)
      Mod.create! name: Forgery(:lorem_ipsum).words(rand(3..6), random: true),
                  author_name: Forgery(:internet).user_name,
                  author: rand > 0.25 ? nil : users.sample,
                  category: categories.sample,
                  github: rand > 50 ? nil : github_url,
                  license: ['MIT', 'GPLv2', 'GPLv3'].sample,
                  license_url: ['https://tldrlegal.com/license/mit-license',
                                'https://tldrlegal.com/license/gnu-general-public-license-v2',
                                'https://tldrlegal.com/license/gnu-general-public-license-v3-(gpl-3)'].sample,
                  official_url: rand > 75 ? nil : "http://" + Forgery(:internet).domain_name,
                  favorites_count: rand(0..100),
                  comments_count: rand(0..150),
                  forum_post_url: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=' + rand(1000..4000).to_s,
                  forum_comments_count: rand(0..150),
                  downloads_count: rand(0..25000),
                  visits_count: rand(0..100000),
                  description: Forgery(:lorem_ipsum).paragraphs(rand(3..6), random: true),
                  summary: Forgery(:lorem_ipsum).words(rand(10..100), random: true)

    end

    ### Mod Versions
    ##################
    Mod.all.each do |mod|
      rand(1..5).times do |i|
        ModVersion.create! game_versions: game_versions[i..(rand(i..game_versions.size))],
                           number: i,
                           mod: mod,
                           released_at: Time.now - (5-i).weeks


      end
      mod_versions = mod.versions.sort_by_older_to_newer

      ### Mod Files
      ##################
      mod_versions.each do |mod_version|
        rand(1..3).times do |i|
          ModFile.create! name: rand > 0.25 ? nil : Forgery(:lorem_ipsum).words(1, random: true),
                          mod: mod,
                          mod_version: mod_version,
                          downloads_count: rand(0..5000),
                          sort_order: i,
                          attachment: File.new(Rails.root.join('spec', 'fixtures', 'test.zip'))
        end
      end

      ### Mod Assets
      ##################
      rand(1..3).times do |i|
        image = Dir[Rails.root.join('spec', 'fixtures', 'sample_images', '*')]
        ModAsset.create! mod: mod,
                         sort_order: i,
                         image: File.new(image.sample)

      end
    end
  end
end