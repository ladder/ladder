source :rubygems

# Server requirements
gem 'unicorn'
gem 'rvm-capistrano'

# Project requirements
gem 'rake'
gem 'haml'
gem 'fabrication'

# Component requirements
gem 'lz4-ruby' # binary compression
gem 'nokogiri' # xml manipulation
gem 'parallel' # multi-core processing
gem 'iso-639'  # english/french lists
gem 'hashdiff' # hash comparison
gem 'amatch'   # string comparison
gem 'oj'       # JSON parser/serializer

# model gems
gem 'bson_ext', :require => 'mongo'
gem 'mongo', :require => 'mongo'
gem 'mongoid', '~> 3.0.0'
gem 'mongoid-tree', :require => 'mongoid/tree'
#gem 'mongoid-grid_fs'
gem 'kaminari', :require => 'kaminari/sinatra'
gem 'tire', '~> 0.5.0'

# linked data gems
gem 'easel', :git => 'git://github.com/mtrudel/easel.git'
gem 'rdf-rdfxml'

# gems for importing existing data
gem 'marc'
gem 'enhanced_marc'
gem 'gyoku'

# gems for service endpoints
gem 'httpclient'
#gem 'zoom', :git => 'git://github.com/bricestacey/ruby-zoom.git'
#gem 'oai'

# Test/debug requirements
group :development do
  gem 'pry-padrino'
  gem 'wirble'
  gem 'ruby-prof'
end

# Padrino master branch
gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'
gem 'padrino-helpers'
gem 'padrino-contrib', :require => 'padrino-contrib/exception_notifier'