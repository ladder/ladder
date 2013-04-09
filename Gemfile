source 'https://rubygems.org'
ruby '2.0.0'

# Debugging stuff
group :development do
  gem 'better_errors'
  gem 'binding_of_caller' # NOT JRUBY COMPATIBLE
  gem 'pry-padrino'
  gem 'wirble'
  gem 'ruby-prof'
end

# Padrino core framework
gem 'padrino-cache' # will include padrino-helpers and padrino-core

# API framework stuff
#gem 'roar', :require => ['roar/representer/json', 'roar/representer/feature/hypermedia']
gem 'rabl'

# MongoDB / ElasticSearch
gem 'mongoid'
gem 'mongoid-pagination'
gem 'mongoid-tree', :require => 'mongoid/tree'
gem 'mongoid-history'
gem 'mongoid-grid_fs'
gem 'tire'

# Model core stuff
gem 'facets', :require => ['facets/hash/recurse']
gem 'hashdiff'
gem 'oj' # NOT JRUBY COMPATIBLE
gem 'amatch' # NOT JRUBY COMPATIBLE

# RDF handling
gem 'rdf-rdfxml'
gem 'easel', :git => 'git://github.com/mtrudel/easel.git', :branch => 'i18n'

# Async / task-based stuff
gem 'sidekiq', :require => ['sidekiq', 'sidekiq/web']
gem 'slim' # WEB UI

# File handling
gem 'lz4-ruby' # NOT JRUBY COMPATIBLE
gem 'snappy' # NOT JRUBY COMPATIBLE

# MARC handling
gem 'marc'
gem 'enhanced_marc'
gem 'nokogiri'
gem 'gyoku'

# TO EXPORT TO CLIENT GEM
# Client Rake tasks
#gem 'padrino'
#gem 'parallel'
#gem 'ruby-filemagic', :require => 'filemagic'
