source 'https://rubygems.org'
ruby '1.9.3'

group :development do
  gem 'better_errors'     # debugging
  gem 'binding_of_caller' # debugging
  gem 'pry-padrino'       # debugging console
  gem 'wirble'            # syntax highlighting
  #gem 'heroku'            # deployment
  #gem 'rvm-capistrano'    # deployment
  #gem 'ruby-prof'
end

group :test do
  gem 'unicorn' # application server
end

# Padrino master branch
gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'
gem 'padrino-contrib', :require => 'padrino-contrib/exception_notifier'

# Front-end stuff
gem 'haml'
gem 'bcrypt-ruby', :require => 'bcrypt'         # for padrino-auth
gem 'kaminari', :require => 'kaminari/sinatra'  # view paging
gem 'iso-639'       # english/french lists
gem 'language_list' # multiple language lists
gem 'ignore_nil'    # cleanly access chained property methods

# Back-end stuff
gem 'rake'
gem 'parallel'      # multi-core processing
#gem 'fabrication'   # object generation

  # gems for service endpoints
  gem 'httpclient'
  #gem 'oai'
  #gem 'zoom', :git => 'git://github.com/bricestacey/ruby-zoom.git'

# Core stuff
gem 'facets', :require => ['facets/hash/recurse']
gem 'lz4-ruby'      # binary compression
gem 'oj'            # JSON parser/serializer
gem 'nokogiri'      # xml manipulation
gem 'hashdiff'      # hash comparison
gem 'amatch'        # string comparison
gem 'marc'
gem 'enhanced_marc'
gem 'gyoku'

gem 'rdf-rdfxml' # linked data
gem 'easel', :git => 'git://github.com/mtrudel/easel.git', :branch => 'i18n'

# Model gems
gem 'tire', :git => 'git://github.com/karmi/tire.git'
gem 'bson_ext', :require => 'mongo'
gem 'mongo', :require => 'mongo'
gem 'mongoid'
gem 'mongoid-tree', :require => 'mongoid/tree'
gem 'mongoid-history', :git => 'git://github.com/aq1018/mongoid-history.git'
#gem 'mongoid-grid_fs'