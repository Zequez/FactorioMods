# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'Open custom log file'
task :log do
  `tail -f log/custom.log`
end

desc 'Clean assets, the straightforward way'
task :assets_clean do
  `rm -r public/assets`# && rm -r tmp/cache/assets`
end

desc 'rails -s -e production'
task :rails_prod do
  `rails s -e production`
end

desc 'Clean assets and precompile them'
task :assets_precompile => [:assets_clean] do
  `rake assets:precompile RAILS_ENV=production RAILS_GROUPS=assets`
end

desc 'Clean assets, precompile them, and start Rails in production'
task :rails_prod_assets => [:assets_precompile, :rails_prod]

desc 'Create fake data'
task fake_data: :environment do
  FakeDataGenerator.new.generate
end

desc 'Fill info_json_name from file name'
task fill_info_json_name: :environment do
  Mod.where(info_json_name: '').each do |mod|
    if ( file = mod.versions.map(&:files).flatten.detect(&:attachment_file_name) )
      name = file.attachment_file_name.scan(/^.*(?=[_-][0-9])/)[0]
      if name
        mod.info_json_name = name
        mod.save!
      end
    end
  end
end
