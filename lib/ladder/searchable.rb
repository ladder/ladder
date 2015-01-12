require 'active_support/concern'
require 'elasticsearch/model'
require 'elasticsearch/model/callbacks'

module Ladder::Searchable
  autoload :Resource, 'ladder/searchable/resource'
  autoload :File,     'ladder/searchable/file'

  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    include Ladder::Searchable::Resource if self.ancestors.include? Ladder::Resource
    include Ladder::Searchable::File     if self.ancestors.include? Ladder::File
  end  
end