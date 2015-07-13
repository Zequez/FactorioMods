source 'https://rubygems.org'
source 'http://rails-assets.org'

ruby "2.1.5"


# Base
########################

gem 'rails', '4.1.1'  # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'sqlite3'         # Use sqlite3 as the database for Active Record

# Assets
########################

group :development, :test, :assets do
  gem 'sass-rails', github: 'rails/sass-rails'  # SASS bindins for Rails
  gem 'sass', '~> 3.3.0'          # CSS with superpowers
  gem 'compass', github: 'Compass/compass'              # SASS on steroids
  gem 'compass-rails', github: 'Compass/compass-rails'  # Compass bindings for Rails
  gem 'breakpoint'                # Media queries sugar
  gem 'susy', '~> 2.0'            # Grids for SASS
  gem 'redcarpet'                 # Markdown
  gem 'uglifier', '>= 1.3.0'      # Use Uglifier as compressor for JavaScript assets
  gem 'coffee-rails', '~> 4.0.0'  # Use CoffeeScript for .js.coffee assets and views
  gem 'jquery-rails'              # Use jquery as the JavaScript library
  gem 'turbolinks'                # Turbolinks makes following links in your web application faster
  gem 'selenium-webdriver'
  gem 'database_cleaner'
end

gem 'font-awesome-sass', '~> 4.3.0'
gem 'haml-rails'
gem 'auto_html'
gem 'rack-zippy'
gem 'jquery-ui-rails'
gem 'kaminari'

group :production do
  gem 'aws-sdk', '< 2.0'
end

# Models
########################

gem 'paperclip', github: 'thoughtbot/paperclip'
gem 'friendly_id'
gem 'youtube_addy'
gem 'cocoon'

# General
########################

gem 'activeadmin', github: 'gregbell/active_admin'    # Administration panel for Rails. Fantastic.
gem 'devise'                    # Authentication system
gem 'cancancan'                    # Authorization adapter
# gem 'jbuilder', '~> 2.0'        # Build JSON APIs with ease
# gem 'sdoc', '~> 0.4.0', group: :doc  # bundle exec rake doc:rails generates the API under doc/api.
# gem 'simple_form'
gem 'reverse_markdown'

group :development do
  gem 'spring'                  # Spring speeds up development by keeping your application running in the background
  gem 'rack-livereload'         # Insert live reload script into the page
  gem 'guard-livereload', require: false  # Guard plugin for a livereload server
end

group :development, :test do
  gem 'spring-commands-rspec'   # Make Rspec use spring to load faster
  gem 'rspec-rails'             # Awesome test framework
  gem 'guard-rspec', require: false # Guard plugin for Rspec
  gem 'factory_girl_rails'      # Models factories for Rspec
  gem 'forgery'                 # Create random text for testing, like lorem ipsum or random names
  gem 'capybara'
end

group :test do
  gem 'webmock'                 # To fake web requests on tests
  gem 'vcr'
end

gem 'nokogiri'                  # To parse HTML, for the scrapper

# gem 'bcrypt', '~> 3.1.7'      # Use ActiveModel has_secure_password
# gem 'unicorn'                 # Use unicorn as the app server
# gem 'capistrano-rails', group: :development # Use Capistrano for deployment
# gem 'debugger', group: [:development, :test]  # Use debugger


gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]