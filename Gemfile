source :rubygems

# Server requirements
gem 'unicorn'
gem 'rvm-capistrano'

# Project requirements
gem 'rake'
gem 'haml'

# Component requirements
gem 'lz4-ruby' # binary compression
gem 'nokogiri' # xml manipulation
gem 'parallel' # multi-core processing
gem 'iso-639'  # english/french lists
gem 'hashdiff' # hash comparison
gem 'amatch'   # string comparison
gem 'yajl-ruby', :require => 'yajl/json_gem'

# model gems
gem 'bson_ext', :require => 'mongo'
gem 'mongo', :require => 'mongo'
gem 'mongoid', '~> 3.0.0'
gem 'mongoid-tree', :require => 'mongoid/tree'
gem 'kaminari', :require => 'kaminari/sinatra'
gem 'tire'

# linked data gems
gem 'easel', :git => 'git://github.com/mtrudel/easel.git'
gem 'rdf-rdfxml'

# gems for importing existing data
gem 'marc'
gem 'gyoku' # NB: this can cause bundle update problems

# gems for service endpoints
gem 'open-uri-cached', :require => 'open-uri/cached'
gem 'zoom', :git => 'git://github.com/bricestacey/ruby-zoom.git'

# Test/debug requirements
#gem 'pry'
gem 'wirble'

# Padrino master branch
gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'
gem 'padrino-helpers'
gem 'padrino-contrib', :require => 'padrino-contrib/exception_notifier'