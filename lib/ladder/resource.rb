require 'mongoid'
require 'active_triples'
require 'json/ld'

module Ladder::Resource
  extend ActiveSupport::Concern

  autoload :Dynamic, 'ladder/resource/dynamic'

  included do
    include Mongoid::Document
    include ActiveTriples::Identifiable

    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
  end

  ##
  # Convenience method to return JSON-LD representation
  def as_jsonld(args = {})
    update_relations(args)
    resource.dump(:jsonld, :standard_prefixes => true)
  end

  ##
  # Populate @resource with attribute/relation values
  #
  # Uses Identifiable#update_resource
  def update_relations(args = {})
    relation_hash = args[:related] ? relations : embedded_relations

    update_resource do |name, prop|
      object = self.send(prop.term)
      next if object.nil?

      objects = object.is_a?(Enumerable) ? object : [object]

      values = objects.map do |obj|
        if obj.is_a?(ActiveTriples::Identifiable)
          if relation_hash.keys.include? name 
            obj.update_relations
            obj.resource.set_value(relation_hash[name].inverse, self.rdf_subject)
            obj
          else
            resource.delete [obj.rdf_subject] if resource.enum_subjects.include? obj.rdf_subject and ! args[:related]
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
    # Default ActiveTriples #property integration
    #
    # @see Mongoid::Document
    def define(field_name, *args)

      if class_name = args.first[:class_name]
        has_and_belongs_to_many field_name, autosave: true, class_name: class_name
      else
        field field_name, localize: true
      end

      property(field_name, *args)
    end
  end

end