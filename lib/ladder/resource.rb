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
  def as_jsonld
    update_resource { update_relations }
    resource.dump(:jsonld)
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
    # Updates ActiveTriples resource relation properties
    #
    # @see Mongoid::Relations
    def update_relations
      resource_class.properties.each do |name, prop|
        if embedded_relations.keys.include? name
          self.send(prop.term).to_a.each do |relation|
            relation.resource.set_value(embedded_relations[name].inverse, self.rdf_subject)
          end
        end
      end
    end

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