require 'ladder/resource'
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

      object = self.send(field_name)

      if relations.keys.include? field_name
        qname_hash[ns][name] = object.to_a.map { |obj| "#{obj.class.name.underscore.pluralize}:#{obj.id}" }
      elsif fields.keys.include? field_name
        qname_hash[ns][name] = read_attribute(field_name)
      end
    end

    qname_hash
  end
  
  private
  
    ##
    # Return a framed, compacted JSON-LD representation
    # by embedding related objects from the graph
    #
    # NB: Will NOT embed related objects with same @type. Spec under discussion, see https://github.com/json-ld/json-ld.org/issues/110
    def as_framed_jsonld
      json_hash = as_jsonld related: true
      context = json_hash['@context']
      frame = {'@context' => context, '@type' => type.first.pname}
      JSON::LD::API.compact(JSON::LD::API.frame(json_hash, frame), context)
    end

  module ClassMethods

    ##
    # Specify type of serialization to use for indexing
    #
    def index(opts = {})
      case opts[:as]
      when :jsonld
        if opts[:related]
          define_method(:as_indexed_json) { |opts = {}| as_framed_jsonld }
        else
          define_method(:as_indexed_json) { |opts = {}| as_jsonld }
        end
      when :qname
        define_method(:as_indexed_json) { |opts = {}| as_qname }
      else
        define_method(:as_indexed_json) { |opts = {}| as_json(except: ['id', '_id']) }
      end
    end

  end
    
end