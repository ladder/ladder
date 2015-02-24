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
    # Populate resource properties from ActiveModel
    #
    # TODO: documentation
    # @param [Type] name1 more information
    # @param [Type] name2 more information
    # @return [Type, nil] describe return value(s)
    def update_resource(opts = {})
      resource_class.properties.each do |name, property|
        value = update_from_field(name) if fields[name]
        value = update_from_relation(name, opts) if relations[name]

        resource.set_value(property.predicate, value) # if value
      end

      resource
    end

    ##
    # Push RDF statement into resource
    #
    # TODO: documentation
    # subject (RDF::Term) - A symbol is converted to an interned Node.
    # predicate (RDF::URI)
    # object (RDF::Resource) - if not a Resource, it is coerced to Literal or Node
    #                depending on if it is a symbol or something other than a Term.
    # @param [Type] name1 more information
    # @param [Type] name2 more information
    # @return [Type, nil] describe return value(s)
    def <<(statement)
      # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
      statement = RDF::Statement.from(statement) unless statement.is_a? RDF::Statement

      # Only push statement if the statement's predicate is defined on the class
      field_name = field_from_predicate(statement.predicate)
      return unless field_name

      # If the object is a URI, see if it is a retrievable model object
      value = Ladder::Resource.from_uri(statement.object) if statement.object.is_a? RDF::URI
      value = yield if block_given?
      value ||= statement.object.to_s

      enum = send(field_name)

      if enum.is_a?(Enumerable)
        enum.send(:push, value) unless enum.include? value
      else
        send("#{field_name}=", value)
      end
    end

    #
    # TODO: documentation
    # @param [Type] name1 more information
    # @param [Type] name2 more information
    # @return [Type, nil] describe return value(s)
    def klass_from_predicate(predicate)
      field_name = field_from_predicate(predicate)
      return unless field_name

      relation = relations[field_name]
      return unless relation

      relation.class_name.constantize
    end

    private

    #
    # TODO: documentation
    # @param [Type] name1 more information
    # @param [Type] name2 more information
    # @return [Type, nil] describe return value(s)
    def field_from_predicate(predicate)
      defined_prop = resource_class.properties.find { |_name, term| term.predicate == predicate }
      return unless defined_prop

      defined_prop.first
    end

    #
    # TODO: documentation
    # @param [Type] name1 more information
    # @param [Type] name2 more information
    # @return [Type, nil] describe return value(s)
    def update_from_field(name)
      if fields[name].localized?
        localized_hash = read_attribute(name)

        unless localized_hash.nil?
          localized_hash.map do |lang, value|
            cast_uri = RDF::URI.new(value)
            cast_uri.valid? ? cast_uri : RDF::Literal.new(value, language: lang)
          end
        end
      else
        send(name)
      end
    end

    #
    # TODO: documentation
    # @param [Type] name1 more information
    # @param [Type] name2 more information
    # @return [Type, nil] describe return value(s)
    def update_from_relation(name, opts = {})
      objects = send(name).to_a

      if opts[:related] || embedded_relations[name]
        # Force autosave of related documents to ensure correct serialization
        methods.select { |i| i[/autosave_documents/] }.each { |m| send m }

        # update inverse relation properties
        relation_def = relations[name]
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
      # Overload ActiveTriples #property
      #
      # @see ActiveTriples::Properties
      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def property(name, opts = {})
        if opts[:class_name]
          mongoid_opts = { autosave: true, index: true }.merge(opts.except(:predicate, :multivalue))
          has_and_belongs_to_many(name, mongoid_opts) unless relations.keys.include? name.to_s
        else
          mongoid_opts = { localize: true }.merge(opts.except(:predicate, :multivalue))
          field(name, mongoid_opts) unless fields[name.to_s]
        end

        opts.except!(*mongoid_opts.keys)

        super
      end

      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def new_from_graph(graph, objects = {}, root_selector = nil)
        # Default to getting the first object in the graph with the same RDF type as this class
        root_selector ||= [nil, RDF.type, resource_class.type]

        root_subject = graph.query(root_selector).first_subject
        return unless root_subject

        # If the subject is an existing model, just retrieve it
        new_object = Ladder::Resource.from_uri(root_subject) if root_subject.is_a? RDF::URI
        new_object ||= new

        # Add object to stack for recursion
        objects[root_subject] = new_object

        graph.query([root_subject]).each_statement do |statement|
          next if objects[statement.object]

          # TODO: If the object is a list, process members individually
#          list = RDF::List.new statement.object, graph
#          binding.pry unless list.empty?

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

    # Factory method to instantiate a Resource from URI
    #
    # TODO: documentation
    # @param [Type] name1 more information
    # @param [Type] name2 more information
    # @return [Type, nil] describe return value(s)
    def self.from_uri(uri)
      klasses = ActiveTriples::Resource.descendants.select(&:name)

      klasses.each do |klass|
        if uri.to_s.include? klass.base_uri.to_s
          object_id = uri.to_s.match(/[0-9a-fA-F]{24}/).to_s

          # Retrieve the object if it's persisted, otherwise return a new one (eg. embedded)
          return klass.parent.where(id: object_id).exists? ? klass.parent.find(object_id) : klass.parent.new
        end
      end

      nil
    end
  end
end
