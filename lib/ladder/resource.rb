require 'mongoid'
require 'active_triples'
require 'json/ld'

module Ladder::Resource
  extend ActiveSupport::Concern

  include Mongoid::Document
  include ActiveTriples::Identifiable

  included do
    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
  end

  ##
  # Convenience method to return JSON-LD representation
  #
  def as_jsonld(opts = {})
    update_resource(opts.slice :related).dump(:jsonld, {standard_prefixes: true}.merge(opts))
  end

  ##
  # Overload ActiveTriples #update_resource
  #
  # @see ActiveTriples::Identifiable
  def update_resource(opts = {})
    relation_hash = opts[:related] ? relations : embedded_relations

    super() do |name, prop|
      # this is a literal property
      if field_def = fields[name]
        value = field_def.localized? ? read_attribute(name).map { |lang, val| RDF::Literal.new(val, language: lang) } : self.send(prop.term)
      end
      
      # this is a relation property
      if relation_def = relation_hash[name]
        objects = self.send(prop.term).to_a
        value = (opts[:related] or embedded_relations == relation_hash) ? objects.map(&:update_resource) : objects.map(&:rdf_subject)
        
        # update inverse relation properties
        objects.each {|object| object.resource.set_value(relation_def.inverse, self.rdf_subject)} if relation_def.inverse
      end

      resource.set_value(prop.predicate, value)
    end

    resource
  end

  module ClassMethods
    
    ##
    # Overload ActiveTriples #property
    #
    # @see ActiveTriples::Properties
    def property(name, opts={})
      if class_name = opts[:class_name]
        mongoid_opts = opts.except(:predicate, :multivalue).merge(autosave: true)
        opts.except! *mongoid_opts.keys

        has_and_belongs_to_many(name, mongoid_opts) unless relations.keys.include? name.to_s
      else
        field(name, localize: true)
      end

      super
    end
  end

end