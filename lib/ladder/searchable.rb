require 'active_support/concern'
require 'elasticsearch/model'
require 'elasticsearch/model/callbacks'

module Ladder::Searchable
  extend ActiveSupport::Concern

  autoload :Background, 'ladder/searchable/background'
  autoload :File,       'ladder/searchable/file'
  autoload :Resource,   'ladder/searchable/resource'

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks unless self.ancestors.include? Ladder::Searchable::Background

    include Ladder::Searchable::Resource if self.ancestors.include? Ladder::Resource
    include Ladder::Searchable::File     if self.ancestors.include? Ladder::File
  end
end