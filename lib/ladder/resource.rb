require 'mongoid'
require 'active_triples'
require 'json/ld'

module Ladder::Resource
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document
    include ActiveTriples::Identifiable
    
    field :_context, type: Hash # for tracking dynamic context
    
    after_find :apply_context
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
      objects = object.is_a?(Enumerable) ? object : [object]

      values = objects.map do |obj|
        if obj.is_a?(ActiveTriples::Identifiable)
          if relation_hash.keys.include?(name)
            obj.update_relations
            obj.resource.set_value(relation_hash[name].inverse, self.rdf_subject)
            obj
          else
            obj.rdf_subject
          end
        else
          obj
        end
      end

      resource.set_value(prop.predicate, values)      
    end

    resource
  end

  ##
  # Dynamic field definition
  def define(field_name, *args)
    # Store context information
    self._context ||= Hash.new(nil)
    self._context[field_name] = args.first[:predicate].to_s

    create_accessors field_name

    # Update resource properties
    resource_class.property(field_name, *args)
  end

  private

    ##
    # Dynamic field accessors
    def create_accessors(field_name)
      define_singleton_method field_name do
        read_attribute(field_name)
      end

      define_singleton_method "#{field_name}=" do |value|
        write_attribute(field_name, value)
      end
    end
    
    ##
    # Apply dynamic fields and properties to this instance
    def apply_context
      return unless self._context

      self._context.each do |field_name, uri|
        if term = RDF::Vocabulary.find_term(uri)
          create_accessors field_name
          
          resource_class.property(field_name, predicate: term)
        end
      end
    end

  public

    module ClassMethods
      ##
      # Default ActiveTriples #property integration
      #
      # @see Mongoid::Document
      def define(field_name, *args)

        if class_name = args.first[:class_name]
          has_and_belongs_to_many field_name, autosave: true, class_name: class_name
        else
          field field_name
        end

        property(field_name, *args)
      end
    end

end