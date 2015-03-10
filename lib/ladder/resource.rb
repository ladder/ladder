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

    included { configure_base_uri }

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
        values = update_from_field(field_name) if fields[field_name]
        values = update_from_relation(field_name, opts[:related]) if relations[field_name]

        [*values].each { |value| resource.set_value(property.predicate, value) }
      end

      resource
    end

    ##
    # Push an RDF::Statement into the object
    #
    # @param [RDF::Statement, Hash, Array] statement @see RDF::Statement#from
    # @return [void]
    #
    # @note This method will overwrite existing statements with the same predicate from the object
    def <<(statement)
      # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
      statement = RDF::Statement.from(statement) unless statement.is_a? RDF::Statement

      # Only push statement if the statement's predicate is defined on the class
      field_name = field_from_predicate(statement.predicate)
      return unless field_name

      value = statement.object.is_a?(RDF::Node) && block_given? ? yield : statement.object

      test_method(field_name, value)
    end

    # TODO
    def test_method(field_name, obj)
      case obj
      when RDF::URI
        set_value field_name, Ladder::Resource.from_uri(obj) || obj.to_s
      when RDF::Literal
        if obj.has_language?
          set_value field_name, obj.object, { language: obj.language }
        else
          set_value field_name, obj.object
        end
      when Array
        set_value field_name, obj.map { |item| test_method(field_name, item.object) }
      else
        set_value field_name, obj
      end
    end

    ##
    # Set values on a field or relation
    #
    # @param [String] field_name ActiveModel attribute name for the field
    # @param [Object] value ActiveModel attribute to be set
    # @return [void]
    def set_value(field_name, value, opts = {})
      return if value.nil?

      field = send(field_name)

      if Mongoid::Relations::Targets::Enumerable == field.class
        field.send(:push, value) unless field.include? value
      elsif opts[:language]
        trans = send("#{field_name}_translations")
        hash = { opts[:language] => value }
#        hash = trans.merge(hash)
        send("#{field_name}_translations=", hash)
      else
        send("#{field_name}=", value)
      end

      value
    end
#

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
        read_attribute(field_name).to_a.map { |lang, value| cast_value(value, language: lang) }
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
          # See if there are multiple statements for this predicate
          s = subgraph.query([root_subject, statement.predicate])

          if s.size > 1
            # field_name = new_object.field_from_predicate statement.predicate
            st = RDF::Statement(statement.subject, statement.predicate, RDF::List(s))
#binding.pry
            new_object.send(:<<, st) { s.to_a }
            next
          end

          next if objects[statement.object]

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

      protected

      ##
      # Set a default base URI based on the global LADDER_BASE_URI
      # constant if it is defined
      #
      # @return [void]
      def configure_base_uri
        configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
      end

      ##
      # Propagate base uri and properties to subclasses
      #
      # @return [void]
      def inherited(subclass)
        # Copy properties from parent to subclass
        resource_class.properties.each do |_name, config|
          subclass.property config.term, predicate: config.predicate, class_name: config.class_name
        end

        subclass.configure_base_uri
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
