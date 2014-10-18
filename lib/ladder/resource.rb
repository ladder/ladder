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
  # Return JSON-LD representation
  #
  # @see ActiveTriples::Resource#dump
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
      object = self.send(prop.term)
      next if object.nil?

      objects = object.is_a?(Enumerable) ? object : [object]

      values = objects.map do |obj|
        if obj.is_a?(ActiveTriples::Identifiable)
          if relation_hash.keys.include? name
            obj.update_resource
            obj.resource.set_value(relation_hash[name].inverse, self.rdf_subject) if relation_hash[name].inverse
            obj
          else
            resource.delete [obj.rdf_subject] if resource.enum_subjects.include? obj.rdf_subject and ! opts[:related]
            obj.rdf_subject
          end
        else
          if fields[name].localized?
            read_attribute(name).map { |lang, val| RDF::Literal.new(val, language: lang) }
          else
            obj
          end
        end
      end

      resource.set_value(prop.predicate, values.flatten)      
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