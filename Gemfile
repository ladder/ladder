source :rubygems
ruby "1.9.3"

gem 'rvm-capistrano'

group :development do
  gem 'wirble'
  gem 'heroku'
  gem 'pry-padrino'
  gem 'better_errors'
  gem 'binding_of_caller'
  #gem 'ruby-prof'
end

group :test do
  gem 'unicorn'
end

# Padrino master branch
gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'
gem 'padrino-contrib', :require => 'padrino-contrib/exception_notifier'

# Project requirements
gem 'rake'
gem 'haml'
#gem 'rabl'

# Component requirements
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'fabrication' # object generation
gem 'lz4-ruby'    # binary compression
gem 'nokogiri'    # xml manipulation
gem 'parallel'    # multi-core processing
gem 'iso-639'     # english/french lists
gem 'language_list' # multiple language lists
#gem 'hashdiff'    # hash comparison
gem 'amatch'      # string comparison
gem 'oj'          # JSON parser/serializer
gem 'ignore_nil'  # cleanly access chained property methods
gem 'whatlanguage',# language detection
      :git => 'git://github.com/niknikjaja/whatlanguage.git'

# Ruby facets methods
gem 'facets', :require => ['facets/hash/recurse']

# model gems
gem 'tire', :git => 'git://github.com/cjbottaro/tire.git', :branch => 'put_mapping'
gem 'kaminari', :require => 'kaminari/sinatra'
gem 'bson_ext', :require => 'mongo'
gem 'mongo', :require => 'mongo'
gem 'mongoid'
gem 'mongoid-tree', :require => 'mongoid/tree'
#gem 'mongoid-grid_fs'
gem 'mongoid-history', :git => 'git://github.com/aq1018/mongoid-history.git'

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