# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'webmock/rspec'
require 'vcr'
require 'paperclip/matchers'
require 'rspec/its'

WebMock.disable_net_connect!(allow_localhost: true)
# Capybara.default_driver = :selenium_phantomjs

Capybara.register_driver :rack_test_json do |app|
  Capybara::RackTest::Driver.new(app, headers: { 'HTTP_ACCEPT' => 'application/json' })
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

VCR.configure do |config|
  config.ignore_request do |request|
    URI(request.uri).host == '127.0.0.1'
  end
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end
  config.cassette_library_dir = "#{::Rails.root}/spec/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
  config.configure_rspec_metadata!
end

Spring.after_fork do
  Dir["app/inputs/*_input.rb"].each { |f| require File.basename(f) }
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include Paperclip::Shoulda::Matchers

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include Devise::TestHelpers, type: :controller

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!


  def sign_in
    @user = create :user
    login_as @user
  end

  def sign_in_admin
    @user = create :user, is_admin: true
    login_as @user
  end

  def sign_in_dev
    @user = create :user, is_dev: true
    login_as @user
  end

  def nfind(tag_name = '', input_name)
    find("#{tag_name}[name^='#{input_name}']")
  end
  
  def last_response
    page.source
  end
end
