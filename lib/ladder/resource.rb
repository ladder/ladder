require 'mongoid'
require 'active_triples'
require 'json/ld'

module Ladder::Resource
  extend ActiveSupport::Concern

  include Mongoid::Document
  include ActiveTriples::Identifiable

  autoload :Dynamic, 'ladder/resource/dynamic'

  included do
    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
  end

  ##
  # Return JSON-LD representation
  #
  # @see ActiveTriples::Resource#dump
  def as_jsonld(opts = {})
    JSON.parse update_resource(opts.slice :related).dump(:jsonld, {standard_prefixes: true}.merge(opts))
  end

  ##
  # Overload ActiveTriples #update_resource
  #
  # @see ActiveTriples::Identifiable
  def update_resource(opts = {})
    super() do |name, prop|
      # this is a literal property
      if field_def = fields[name]
        if field_def.localized?
          value = read_attribute(name).map { |lang, val| RDF::Literal.new(val, language: lang) }
        else
          value = self.send(name)
        end
      end

      # this is a relation property
      if relation_def = relations[name]
        objects = self.send(prop.term).to_a

        if opts[:related] or embedded_relations[name]
          value = objects.map(&:update_resource)

          # update inverse relation properties
          objects.each { |object| object.resource.set_value(relation_def.inverse, self.rdf_subject) } if relation_def.inverse
        else
          value = objects.map(&:rdf_subject)
          
          # remove inverse relation properties
          objects.each { |object| resource.delete [object.rdf_subject] }
        end

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
        mongoid_opts = {autosave: true, index: true}.merge(opts.except(:predicate, :multivalue))
        opts.except! *mongoid_opts.keys

        has_and_belongs_to_many(name, mongoid_opts) unless relations.keys.include? name.to_s
      else
        field(name, localize: true) unless fields[name.to_s]
      end

      super
    end
  end

end