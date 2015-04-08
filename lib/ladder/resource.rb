require 'mongoid'
require 'active_triples'
require 'ladder/resource/pushable'
require 'ladder/resource/serializable'

module Ladder
  module Resource
    autoload :Dynamic, 'ladder/resource/dynamic'

    extend ActiveSupport::Concern

    include Mongoid::Document
    include ActiveTriples::Identifiable
    include Ladder::Configurable
    include Ladder::Resource::Pushable
    include Ladder::Resource::Serializable

    delegate :rdf_label, to: :update_resource

    ##
    # Update the delegated ActiveTriples::Resource from
    # ActiveModel properties & relations
    #
    # @param [Hash] opts options to pass to Mongoid / ActiveTriples
    # @option opts [Boolean] :related whether to include related resources
    # @return [ActiveTriples::Resource] resource for the object
    def update_resource
      resource_class.properties.each do |field_name, property|
        values = update_from_field(field_name) if fields[field_name]
        values = update_from_relation(field_name) if relations[field_name]

        resource.set_value(property.predicate, values)
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
    # Set values on a defined relation
    #
    # @param [String] field_name ActiveModel attribute name for the field
    # @param [Array<Object>] obj objects (usually Ladder::Resources) to be set
    # @return [Ladder::Resource, nil]
    def update_relation(field_name, *obj)
      # Should be an Array of RDF::Term objects
      return unless obj

      obj.map! { |item| item.is_a?(RDF::URI) ? Ladder::Resource.from_uri(item) : item }
      relation = send(field_name)

      if Mongoid::Relations::Targets::Enumerable == relation.class
        obj.map { |item| relation.send(:push, item) unless relation.include? item }
      else
        send("#{field_name}=", obj.size > 1 ? obj : obj.first)
      end
    end

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
        # Cast DateTimes with 00:00:00 or Date stored as Times in Mongoid to xsd:date
        # FIXME: this should NOT be applied for fields that are typed as Time
        value.midnight == value ? RDF::Literal.new(value.to_date) : RDF::Literal.new(value.to_datetime)
      else
        RDF::Literal.new(value, opts)
      end
    end

    ##
    # Update the delegated ActiveTriples::Resource from a field
    #
    # @param [String] field_name ActiveModel attribute name for the field
    # @return [Object]
    def update_from_field(field_name)
      if fields[field_name].localized?
        read_attribute(field_name).to_a.map { |lang, value| cast_value(value, language: lang) }.flatten
      else
        cast_value send(field_name)
      end
    end

    ##
    # Update the delegated ActiveTriples::Resource from a relation
    #
    # @param [String] field_name ActiveModel attribute name for the relation
    # @param [Boolean] related whether to include related objects
    # @return [Enumerable]
    def update_from_relation(field_name)
      objects = send(field_name).to_a

      if relations[field_name]
        # Force autosave of related documents to ensure correct serialization
#        methods.select { |i| i[/autosave_documents/] }.each { |m| send m }

        # update inverse relation properties
        relation = relations[field_name]
        objects.each { |object| object.resource.set_value(relation.inverse, rdf_subject) } if relation.inverse
        # TODO: mark-and-sweep
#        objects.map(&:update_resource)
      else
        # remove inverse relation properties
        objects.each { |object| resource.delete [object.rdf_subject] }
        objects.map(&:rdf_subject)
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
