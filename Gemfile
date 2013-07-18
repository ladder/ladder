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

# Deployment stuff
gem 'knife-solo'
gem 'berkshelf'

# Padrino core framework
gem 'padrino-cache' # will include padrino-helpers and padrino-core

# MongoDB / ElasticSearch
gem 'mongoid'
gem 'mongoid-pagination'
gem 'mongoid-tree', :require => 'mongoid/tree'
gem 'mongoid-history'
gem 'mongoid-grid_fs'
gem 'tire'

# Model / core
gem 'facets', :require => ['facets/hash/recurse']
gem 'hashdiff'
gem 'oj' # NOT JRUBY COMPATIBLE
gem 'amatch' # NOT JRUBY COMPATIBLE

# Async / task-based stuff
gem 'sidekiq', :require => ['sidekiq', 'sidekiq/web']
gem 'kiqstand'
gem 'slim' # WEB UI

# API framework
#gem 'roar', :require => ['roar/representer/json', 'roar/representer/feature/hypermedia']
gem 'rabl'
gem 'email_veracity'

# RDF handling
gem 'rdf-rdfxml'
gem 'easel', :git => 'git://github.com/mtrudel/easel.git', :branch => 'i18n'

# File handling
gem 'lz4-ruby' # NOT JRUBY COMPATIBLE
gem 'snappy' # NOT JRUBY COMPATIBLE

# MARC handling
gem 'marc'
gem 'enhanced_marc'
gem 'nokogiri'
gem 'gyoku'

#####################################
#
# TEMPORARY UI
#
# Viewer app
gem 'padrino'
gem 'padrino-core'
gem 'padrino-helpers'
#gem 'padrino-mailer'
#gem 'padrino-contrib', :require => 'padrino-contrib/exception_notifier'
gem 'haml'
gem 'bcrypt-ruby', :require => 'bcrypt'         # for padrino-auth
gem 'kaminari', :git => 'git://github.com/amatsuda/kaminari.git', :require => 'kaminari/sinatra'  # view paging
gem 'iso-639'       # english/french lists
gem 'language_list' # multiple language lists
gem 'ignore_nil'    # cleanly access chained property methods
