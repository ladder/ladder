require 'mongoid'
require 'active_triples'
require 'ladder/resource/pushable'
require 'ladder/resource/serializable'

require_relative '../rdf/model/uri'

module Ladder
  module Resource
    autoload :Dynamic, 'ladder/resource/dynamic'

    extend ActiveSupport::Concern

    include Mongoid::Document
    include ActiveTriples::Identifiable
    include Ladder::Configurable
#    include Ladder::Resource::Pushable
    include Ladder::Resource::Serializable

    delegate :rdf_label, to: :update_resource

    ##
    # Update the delegated ActiveTriples::Resource from
    # ActiveModel properties & relations
    #
    # @param [Hash] opts options to pass to Mongoid / ActiveTriples
    # @return [ActiveTriples::Resource] resource for the object
    def update_resource
      # Delete existing statements for the object
      resource.delete [rdf_subject]

      resource_class.properties.each do |field_name, property|
        object = case read_attribute(field_name)
        when send(field_name) # Regular field
           cast_value send(field_name)
        when nil # Relation
           send(field_name).to_a.map(&:rdf_subject)
        else # Localized field
          read_attribute(field_name).map { |lang, value| cast_value(value, language: lang) }
        end

        # TODO: For fields with 00:00:00 that are NOT typed as Time, cast to xsd:date
        # value.midnight == value ? RDF::Literal.new(value.to_date) : RDF::Literal.new(value.to_datetime)

        resource.set_value(property.predicate, object)
      end

      resource
    end

    ##
    # Retrieve the class for a relation, based on its defined RDF predicate
    #
    # @param [RDF::URI] predicate a URI for the RDF::Term
    # @return [Ladder::Resource, Ladder::File, nil] related class
    def klass_from_predicate(predicate)
      field_name = field_from_predicate(predicate)
      return unless field_name

      relation = relations[field_name]
      return unless relation

      relation.class_name.constantize
    end

    ##
    # Retrieve the attribute name for a field or relation,
    # based on its defined RDF predicate
    #
    # @param [RDF::URI] predicate a URI for the RDF::Term
    # @return [String, nil] name for the attribute
    def field_from_predicate(predicate)
      defined_prop = resource_class.properties.find { |_field_name, term| term.predicate == predicate }
      return unless defined_prop

      defined_prop.first
    end

    private

    ##
    # Cast values from Mongoid types to RDF types
    #
    # @param [Object] value ActiveModel attribute to be cast
    # @param [Hash] opts options to pass to RDF::Literal
    # @return [RDF::Term]
    def cast_value(value, opts = {})
      case value
      when Array
        value.map { |v| cast_value(v, opts) }
      when String
        cast_uri = RDF::URI.new(value)
        cast_uri.valid? ? cast_uri : RDF::Literal.new(value, opts)
      when Time
        RDF::Literal.new(value.to_datetime)
      else
        RDF::Literal.new(value, opts)
      end
    end

    public

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
          mongoid_opts[:inverse_of] = nil if Ladder::Config.settings[:one_sided_relations]

          has_and_belongs_to_many(field_name, mongoid_opts) unless relations[field_name.to_s]
        else
          mongoid_opts = { localize: Ladder::Config.settings[:localize_fields] }.merge(opts.except(:predicate, :multivalue))
          field(field_name, mongoid_opts) unless fields[field_name.to_s]
        end

        opts.except!(*mongoid_opts.keys)

        super
      end

      ##
      # Create a new instance of this class, populated with values
      # and related objects from a given RDF::Graph for this model.
      #
      # By default, the graph will be traversed starting with the first
      # node that matches the same RDF.type as this class; however, an
      # optional RDF::Queryable pattern can be provided, @see RDF::Queryable#query
      #
      # As nodes are traversed in the graph, the instantiated objects
      # will be added to a Hash that is passed recursively, in order to
      # prevent infinite traversal in the case of cyclic graphs (ie.
      # mark-and-sweep graph traversal).
      #
      # @param [RDF::Graph] graph an RDF::Graph to traverse
      # @param [Hash] objects a keyed Hash of already-created objects in the graph
      # @param [RDF::Query, RDF::Statement, Array(RDF::Term), Hash] pattern a query pattern
      # @return [Ladder::Resource, nil] an instance of this class
      def new_from_graph(graph, objects = {}, pattern = nil)
        # Default to getting the first object in the graph with the same RDF type as this class
        pattern ||= [nil, RDF.type, resource_class.type]

        root_subject = graph.query(pattern).first_subject
        return unless root_subject

        # If the subject is an existing model, just retrieve it
        new_object = Ladder::Resource.from_uri(root_subject) if root_subject.is_a? RDF::URI
        new_object ||= new

        # Add object to stack for recursion
        objects[root_subject] = new_object

        subgraph = graph.query([root_subject])

        subgraph.each_statement do |statement|
          # Group statements for this predicate
          stmts = subgraph.query([root_subject, statement.predicate])

          if stmts.size > 1
            # We have already set this value in a prior pass
            next if new_object.read_attribute new_object.field_from_predicate statement.predicate

            # If there are multiple statements for this predicate, pass an array
            statement.object = RDF::Node.new
            new_object.send(:<<, statement) { stmts.objects.to_a } # TODO: implement #set_value instead

          elsif statement.object.is_a? RDF::Node
            next if objects[statement.object]

            # If the object is a BNode, dereference the relation
            objects[statement.object] = new_object.send(:<<, statement) do  # TODO: implement #set_value instead
              klass = new_object.klass_from_predicate(statement.predicate)
              klass.new_from_graph(graph, objects, [statement.object]) if klass
            end

          else new_object << statement
          end
        end # end each_statement

        new_object
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
