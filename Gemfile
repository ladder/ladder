source 'https://rubygems.org'
ruby '1.9.3'

# Debugging stuff
group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-padrino'
  gem 'wirble'
  #gem 'ruby-prof'
end

# Padrino core framework
gem 'padrino-core'
gem 'padrino-cache'
gem 'padrino-helpers'

# API framework stuff
#gem 'roar', :require => ['roar/representer/json', 'roar/representer/feature/hypermedia']
gem 'rabl'

# MongoDB / ElasticSearch
gem 'mongoid'
gem 'mongoid-pagination'
gem 'mongoid-tree', :require => 'mongoid/tree'
gem 'mongoid-history', :git => 'git://github.com/aq1018/mongoid-history.git'
gem 'mongoid-grid_fs'

gem 'tire', :git => 'git://github.com/karmi/tire.git'

gem 'bson_ext', :require => 'mongo'
gem 'mongo', :require => 'mongo'

# Async / task-based stuff
gem 'parallel' # TO REMOVE
gem 'sidekiq', :require => ['sidekiq', 'sidekiq/web']
gem 'slim'

# Model core stuff
gem 'facets', :require => ['facets/hash/recurse']
gem 'oj'
gem 'hashdiff'
gem 'amatch'

# File handling
gem 'lz4-ruby'
gem 'snappy'
#gem 'ruby-filemagic', :require => 'filemagic' # TO REMOVE  mime = MIME::Type.new(FileMagic.fm(:mime).buffer(data_string))

# MARC handling
gem 'marc'
gem 'enhanced_marc'
gem 'nokogiri'
gem 'gyoku'

# RDF handling
gem 'rdf-rdfxml'
gem 'easel', :git => 'git://github.com/mtrudel/easel.git', :branch => 'i18n'
