require 'mongoid'
require 'active_triples'

require 'ladder/resource/serializable'
#require 'ladder/resource/persistable'
require 'ladder/resource/pushable'

module Ladder
  module Resource
    autoload :Dynamic, 'ladder/resource/dynamic'

    extend ActiveSupport::Concern

    include Mongoid::Document
    include ActiveTriples::Identifiable
    include Ladder::Configurable

    include Ladder::Resource::Serializable
#    include Ladder::Resource::Persistable
    include Ladder::Resource::Pushable

    delegate :rdf_label, to: :update_resource

    ##
    # Update the delegated ActiveTriples::Resource from
    # ActiveModel properties & relations
    #
    # @param [Hash] opts options to pass to Mongoid / ActiveTriples
    # @return [ActiveTriples::Resource] resource for the object
    def update_resource(opts = {})
      # Delete existing statements for the object
      resource.delete [rdf_subject]
      resource.set_value(RDF.type, resource_class.type)

      attributes_to_statements(opts).each { |statement| resource << statement }

      resource
    end

    private

    ##
    # Generate a list of subject, predicate, object arrays from
    # attributes on the document, suitable for creating
    # RDF::Statements or sending to ActiveTriples::Resource#set_value
    #
    # @param [Hash] opts options to pass to RDF::Literal
    # @option opts [Boolean] :related whether to include related resources (default: false)
    # @return [Array<RDF::Term, RDF::Resource>] an array of RDF::Terms
    def attributes_to_statements(opts = {})
      statements = []

      resource_class.properties.each do |field_name, property|
        if fields[field_name] && fields[field_name].localized?
          objects = read_attribute(field_name).map { |lang, value| attribute_to_rdf(value, language: lang) }
        else
          objects = attribute_to_rdf(send(field_name))
        end

        [*objects].each { |object| statements << [rdf_subject, property.predicate, object] }

        if embedded_relations[field_name] || (relations[field_name] && opts[:related])
          send(field_name).to_a.each do |related_object|
            related_object.update_resource.statements.each { |statement| statements << statement }
          end
        end
      end

      statements
    end

    ##
    # Cast values from Mongoid types to RDF types
    #
    # @param [Object] value ActiveModel attribute value to be cast
    # @param [Hash] opts options to pass to RDF::Literal
    # @option opts [Boolean] :language language to use for language-typed RDF::Literals
    # @return [Array<RDF::Term>, RDF::Term] a cast value(s)
    def attribute_to_rdf(value, opts = {})
      if value.is_a? Enumerable
        value.map { |v| attribute_to_rdf(v, opts) }
      elsif value.is_a? ActiveTriples::Identifiable
        value.rdf_subject
      elsif value.is_a? String
        RDF::URI.intern(value).valid? ? RDF::URI.intern(value) : RDF::Literal.new(value, opts)
      elsif value.is_a? Time
        RDF::Literal.new(value.to_datetime)
      else
        RDF::Literal.new(value, opts)
      end
    end

    module ClassMethods
      ##
      # Define a Mongoid field/relation on the class as well as
      # an RDF property on the delegated resource
      #
      # @see ActiveTriples::Resource#property
      # @see ActiveTriples::Properties
      #
      # @param [String] field_name ActiveModel attribute name for the field
      # @param [Hash] opts options to pass to Mongoid / ActiveTriples
      # @return [ActiveTriples::Resource] a modified resource
      def property(field_name, opts = {})
        if opts[:class_name]
          mongoid_opts = { autosave: true, index: true }.merge(opts.except(:predicate, :multivalue))
          # TODO: add/fix tests for this behaviour when true
          # mongoid_opts[:inverse_of] = nil if Ladder::Config.settings[:one_sided_relations]

          has_and_belongs_to_many(field_name, mongoid_opts) unless relations[field_name.to_s]
        else
          mongoid_opts = { localize: Ladder::Config.settings[:localize_fields] }.merge(opts.except(:predicate, :multivalue))
          field(field_name, mongoid_opts) unless fields[field_name.to_s]
        end

        opts.except!(*mongoid_opts.keys)

        super
      end
    end

    ##
    # Return a persisted instance of a Ladder::Resource from its
    # RDF subject URI, without knowing the resource class.
    #
    # If there is no persisted instance for the URI, but the class
    # is identifiable, then return a new instance of that class
    #
    # @param [RDF::URI] uri RDF subject URI for the resource
    # @return [Ladder::Resource] a resource instance
    def self.from_uri(uri)
      klass = Ladder::Config.models.find { |k| uri.to_s.include? k.resource_class.base_uri.to_s }

      if klass
        object_id = uri.to_s.match(/[0-9a-fA-F]{24}/).to_s

        # Retrieve the object if it's persisted, otherwise return a new one (eg. embedded)
        return klass.where(id: object_id).exists? ? klass.find(object_id) : klass.new
      end
    end
  end
end
