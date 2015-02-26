require 'mongoid'
require 'active_triples'

module Ladder
  module Resource
    autoload :Dynamic, 'ladder/resource/dynamic'
    autoload :Serializable, 'ladder/resource/serializable'

    extend ActiveSupport::Concern

    include Mongoid::Document
    include ActiveTriples::Identifiable
    include Ladder::Resource::Serializable

    included do
      configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
    end

    delegate :rdf_label, to: :update_resource

    ##
    # Update the delegated ActiveTriples::Resource from
    # ActiveModel properties & relations
    #
    # @param [Hash] opts options to pass to Mongoid / ActiveTriples
    # @option opts [Boolean] :related whether to include related resources
    # @return [ActiveTriples::Resource] resource for the object
    def update_resource(opts = {})
      resource_class.properties.each do |field_name, property|
        value = update_from_field(field_name) if fields[field_name]
        value = update_from_relation(field_name, opts[:related]) if relations[field_name]

        resource.set_value(property.predicate, value) # if value
      end

      resource
    end

    ##
    # Push an RDF::Statement into the object
    #
    # @param [RDF::Statement, Hash, Array] statement @see RDF::Statement#from
    # @return [void]
    def <<(statement)
      # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
      statement = RDF::Statement.from(statement) unless statement.is_a? RDF::Statement

      # Only push statement if the statement's predicate is defined on the class
      field_name = field_from_predicate(statement.predicate)
      return unless field_name

      # If the object is a URI, see if it is a retrievable model object
      value = Ladder::Resource.from_uri(statement.object) if statement.object.is_a? RDF::URI

      # TODO: tidy this code
      # subject (RDF::Term) - A symbol is converted to an interned Node.
      # predicate (RDF::URI)
      # object (RDF::Resource) - if not a Resource, it is coerced to Literal or Node
      #                depending on if it is a symbol or something other than a Term.
      value = yield if block_given?
      value ||= statement.object.to_s

      enum = send(field_name)

      if enum.is_a?(Enumerable)
        enum.send(:push, value) unless enum.include? value
      else
        send("#{field_name}=", value)
      end
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

    private

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

    ##
    # Update the delegated ActiveTriples::Resource from a field
    #
    # @param [String] field_name ActiveModel attribute name for the field
    # @return [void]
    def update_from_field(field_name)
      if fields[field_name].localized?
        localized_hash = read_attribute(field_name)

        unless localized_hash.nil?
          localized_hash.map do |lang, value|
            cast_uri = RDF::URI.new(value)
            cast_uri.valid? ? cast_uri : RDF::Literal.new(value, language: lang)
          end
        end
      else
        send(field_name)
      end
    end

    ##
    # Update the delegated ActiveTriples::Resource from a relation
    #
    # @param [String] field_name ActiveModel attribute name for the relation
    # @param [Boolean] related whether to include related objects
    # @return [void]
    def update_from_relation(field_name, related = false)
      objects = send(field_name).to_a

      if related || embedded_relations[field_name]
        # Force autosave of related documents to ensure correct serialization
        methods.select { |i| i[/autosave_documents/] }.each { |m| send m }

        # update inverse relation properties
        relation_def = relations[field_name]
        objects.each { |object| object.resource.set_value(relation_def.inverse, rdf_subject) } if relation_def.inverse
        objects.map(&:update_resource)
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
          has_and_belongs_to_many(field_name, mongoid_opts) unless relations.keys.include? field_name.to_s
        else
          mongoid_opts = { localize: true }.merge(opts.except(:predicate, :multivalue))
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
      # prevent infinite traversal in the case of cyclic graphs.
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

        graph.query([root_subject]).each_statement do |statement|
          next if objects[statement.object]

          # TODO: If the object is a list, process members individually
          # list = RDF::List.new statement.object, graph
          # binding.pry unless list.empty?

          # If the object is a BNode, dereference the relation
          if statement.object.is_a? RDF::Node
            klass = new_object.klass_from_predicate(statement.predicate)
            next unless klass

            object = klass.new_from_graph(graph, objects)
            next unless object

            objects[statement.object] = object
            new_object.send(:<<, statement) { object }
          else
            new_object << statement
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
      klasses = ActiveTriples::Resource.descendants.select(&:name)
      klass = klasses.find { |k| uri.to_s.include? k.base_uri.to_s }

      if klass
        object_id = uri.to_s.match(/[0-9a-fA-F]{24}/).to_s

        # Retrieve the object if it's persisted, otherwise return a new one (eg. embedded)
        return klass.parent.where(id: object_id).exists? ? klass.parent.find(object_id) : klass.parent.new
      end
    end
  end
end
