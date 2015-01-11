module Ladder::Searchable::Resource
  extend ActiveSupport::Concern

  ##
  # Generate a qname-based JSON representation
  #
  def as_qname(opts = {})
    qname_hash = type.empty? ? {} : {rdf: {type: type.first.pname }}

    resource_class.properties.each do |field_name, property|
      ns, name = property.predicate.qname
      qname_hash[ns] ||= Hash.new

      object = self.send(field_name)

      if relations.keys.include? field_name
        if opts[:related]
          qname_hash[ns][name] = object.to_a.map { |obj| obj.as_qname }
        else
          qname_hash[ns][name] = object.to_a.map { |obj| "#{obj.class.name.underscore.pluralize}:#{obj.id}" }
        end
      elsif fields.keys.include? field_name
        qname_hash[ns][name] = read_attribute(field_name)
      end
    end

    qname_hash
  end
  
  def as_indexed_json(opts = {})
    respond_to?(:serialized_json) ? serialized_json : as_json(except: [:id, :_id])
  end

  private

    ##
    # Return a framed, compacted JSON-LD representation
    # by embedding related objects from the graph
    #
    # NB: Will NOT embed related objects with same @type. Spec under discussion, see https://github.com/json-ld/json-ld.org/issues/110
    def as_framed_jsonld
      # FIXME: Force autosave of related documents using Mongoid-defined methods
      # Required for explicit autosave prior to after_update index callbacks
      methods.select{|i| i[/autosave_documents/] }.each{|m| send m}
      json_hash = as_jsonld related: true

      context = json_hash['@context']
      frame = {'@context' => context, '@type' => type.first.pname}
      JSON::LD::API.compact(JSON::LD::API.frame(json_hash, frame), context)
    end

  module ClassMethods

    ##
    # Specify type of serialization to use for indexing
    #
    def index_for_search(opts = {}, &block)
      raise Mongoid::Errors::InvalidValue.new(Block, NilClass) unless block_given?

      define_method(:serialized_json, block)
    end

  end
    
end