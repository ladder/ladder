source :rubygems
ruby "1.9.3"

group :development do
  gem 'wirble'
  gem 'heroku'
  gem 'pry-padrino'
  gem 'better_errors'
  gem 'binding_of_caller'
  #gem 'ruby-prof'
end

# Project requirements
gem 'rake'
gem 'haml'

# Component requirements
gem 'fabrication' # object generation
gem 'lz4-ruby'    # binary compression
gem 'nokogiri'    # xml manipulation
gem 'parallel'    # multi-core processing
gem 'iso-639'     # english/french lists
gem 'hashdiff'    # hash comparison
gem 'amatch'      # string comparison
gem 'oj'          # JSON parser/serializer

# model gems
gem 'tire', :git => 'git://github.com/cjbottaro/tire.git', :branch => 'put_mapping'
gem 'kaminari', :require => 'kaminari/sinatra'
gem 'bson_ext', :require => 'mongo'
gem 'mongo', :require => 'mongo'
gem 'mongoid'
gem 'mongoid-tree', :require => 'mongoid/tree'
#gem 'mongoid-grid_fs'
gem 'recursive-open-struct' # access hashes using object notation
gem 'ignore_nil'            # cleanly access chained property methods

# linked data gems
gem 'easel', :path => '~/Documents/easel' #:git => 'git://github.com/mtrudel/easel.git'
gem 'rdf-rdfxml'

# gems for importing existing data
gem 'marc'
gem 'enhanced_marc'
gem 'gyoku'

# gems for service endpoints
gem 'httpclient'
#gem 'oai'
#gem 'zoom', :git => 'git://github.com/bricestacey/ruby-zoom.git'

# Padrino master branch
gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'
gem 'padrino-contrib', :require => 'padrino-contrib/exception_notifier'
