# Defines our constants
PADRINO_ENV  = ENV['PADRINO_ENV'] ||= ENV['RACK_ENV'] ||= 'development'  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

##
# ## Enable devel logging
#
Padrino::Logger::Config[:development][:log_level]  = :devel
# Padrino::Logger::Config[:development][:stream]     = :to_file
Padrino::Logger::Config[:development][:log_static] = true

if 'development' == PADRINO_ENV
  Mongoid.logger = Padrino.logger
  Moped.logger = Padrino.logger
  Tire.configure { logger Padrino.logger, level: Padrino.logger.level }
end

#
# ## Configure your I18n
#
require 'i18n/backend/fallbacks'
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.default_locale = :en
I18n.fallbacks[:fr] = [ :fr, :en ]

# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
  Encoding.default_internal = 'UTF-8'
  Encoding.default_external = 'UTF-8'
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
  # Load other config files
  require File.join(PADRINO_ROOT, 'config', 'rabl.rb')
  require File.join(PADRINO_ROOT, 'config', 'sidekiq.rb')
end

Padrino.load!
