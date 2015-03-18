require 'bundler/setup'
Bundler.setup

require 'ladder'
require 'awesome_print'
require 'pry'
require 'simplecov'
SimpleCov.start

Dir['./spec/shared/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.tty = true

  # Uncomment the following line to get errors and backtrace for deprecation warnings
  # config.raise_errors_for_deprecations!

  # Use the specified formatter
  config.formatter = :documentation

  config.before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG

    require 'i18n/backend/fallbacks'
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.fallbacks[:en] = [:en, :sv]
    I18n.enforce_available_locales = false

    Ladder::Config.settings[:base_uri] = 'http://example.org'
  end

  config.before :each do
    Mongoid.purge!
  end
end
