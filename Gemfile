source 'https://rubygems.org'
ruby '1.9.3'

group :development do
  gem 'better_errors'     # debugging
  gem 'binding_of_caller' # debugging
  gem 'pry-padrino'       # debugging console
  gem 'wirble'            # syntax highlighting
  gem 'heroku'            # deployment
  gem 'rvm-capistrano'    # deployment
  #gem 'ruby-prof'
end

gem 'unicorn' # application server

# Padrino master branch
gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'
gem 'padrino-contrib', :require => 'padrino-contrib/exception_notifier'

# Project requirements
gem 'rake'
gem 'haml'
#gem 'rabl'

# Component requirements
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'fabrication'   # object generation
gem 'lz4-ruby'      # binary compression
gem 'nokogiri'      # xml manipulation
gem 'parallel'      # multi-core processing
gem 'iso-639'       # english/french lists
gem 'language_list' # multiple language lists
gem 'amatch'        # string comparison
gem 'oj'            # JSON parser/serializer
gem 'ignore_nil'    # cleanly access chained property methods
gem 'whatlanguage', # language detection
  :git => 'git://github.com/niknikjaja/whatlanguage.git'
#gem 'charlock_holmes', #encoding detection
# :require => 'charlock_holmes/string'
gem 'hashdiff'     # hash comparison

# Ruby facets methods
gem 'facets', :require => ['facets/hash/recurse']

# model gems
gem 'tire', :git => 'git://github.com/karmi/tire.git'
gem 'kaminari', '>=0.14', :require => 'kaminari/sinatra' # NB: shouldn't require version pinning
gem 'bson_ext', :require => 'mongo'
gem 'mongo', :require => 'mongo'
gem 'mongoid'
gem 'mongoid-tree', :require => 'mongoid/tree'
gem 'mongoid-history'
#gem 'mongoid-grid_fs'

# linked data gems
gem 'easel', :git => 'git://github.com/mtrudel/easel.git', :branch => 'i18n'
gem 'rdf-rdfxml'

# gems for importing existing data
gem 'marc'
gem 'enhanced_marc'
gem 'gyoku'

# gems for service endpoints
gem 'httpclient'
#gem 'oai'
#gem 'zoom', :git => 'git://github.com/bricestacey/ruby-zoom.git'