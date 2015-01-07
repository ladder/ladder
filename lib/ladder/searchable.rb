require 'ladder/resource'
require 'elasticsearch/model'
require 'elasticsearch/model/callbacks'

module Ladder::Searchable
  extend ActiveSupport::Concern

  autoload :Resource, 'ladder/searchable/resource'
  autoload :File,     'ladder/searchable/file'

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    include Ladder::Searchable::Resource if self.ancestors.include? Ladder::Resource
    include Ladder::Searchable::File     if self.ancestors.include? Ladder::File
  end  
end