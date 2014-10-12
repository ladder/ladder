require 'active_support'
require 'elasticsearch/model'
require 'elasticsearch/model/callbacks'

module Ladder::Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  end

  ##
  # Generate a qname-based JSON representation
  #
  def as_qname
    qname_hash = type.empty? ? {} : {rdf: {type: type.first.pname }}

    resource_class.properties.each do |field_name, property|
      ns, name = property.predicate.qname
      qname_hash[ns] ||= Hash.new

      if embedded_relations.keys.include? field_name
        qname_hash[ns][name] = self.send(field_name).map(&:as_qname)
      elsif fields.keys.include? field_name
        qname_hash[ns][name] = read_attribute(field_name)
      end
    end

    qname_hash.to_json
  end

  module ClassMethods

    ##
    # Specify type of serialization to use for indexing
    #
    def index(opts={})
      case opts[:as]
      when :jsonld
        define_method(:as_indexed_json) { |opts = {}| as_jsonld opts.except(:as) }
      when :qname
        define_method(:as_indexed_json) { |opts = {}| as_qname }
      else
        define_method(:as_indexed_json) { |opts = {}| as_document.as_json(except: ['id', '_id']) }
      end
    end

  end
    
end