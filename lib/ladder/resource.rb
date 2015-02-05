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
    def <<(statement, &block)
      # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
      statement = RDF::Statement.from(statement) unless statement.is_a? RDF::Statement

      # Only push statement if the statement's predicate is defined on the class
      defined_prop = resource_class.properties.find { |_name, term| term.predicate == statement.predicate }
      return unless defined_prop

      field_name = defined_prop.first

      # If the object is a URI, see if it is a retrievable model object
      value = Ladder::Resource.new_from_uri(statement.object) if statement.object.is_a? RDF::URI
      value = yield(field_name) if block_given?
      value ||= statement.object.to_s

      send(field_name).is_a?(Enumerable) ? send(:push, field_name.to_sym => value) : send("#{field_name}=", value)
    end

    private

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
      def property(name, opts = {})
        if opts[:class_name]
          mongoid_opts = { autosave: true, index: true }.merge(opts.except(:predicate, :multivalue))
          opts.except!(*mongoid_opts.keys)

          has_and_belongs_to_many(name, mongoid_opts) unless relations.keys.include? name.to_s
        else
          # TODO: allow disabling localization
          field(name, localize: true) unless fields[name.to_s]
        end

        super
      end

      def new_from_graph(graph, objects = {})
        # Get the first object in the graph with the same RDF type as this class
        root_subject = graph.query([nil, RDF.type, resource_class.type]).first_subject
        return unless root_subject

        # If the subject is an existing model, just retrieve it
        new_object = Ladder::Resource.new_from_uri(root_subject) if root_subject.is_a? RDF::URI
        new_object ||= new

        # Add object to stack for recursion
        objects[root_subject] = new_object

        graph.query([root_subject]).each_statement do |statement|
          # Dereference the object if it's a BNode
          if statement.object.is_a? RDF::Node
            new_object.send(:<<, statement) do |field_name|

              # If we haven't processed this object before, do so now
              unless objects[statement.object]
                relation = relations[field_name]
                return unless relation

                # create the new object
                klass = relation.class_name.constantize
                objects[statement.object] = klass.new_from_graph(graph, objects)
              end

              objects[statement.object]
            end
          else
            new_object << statement
          end
        end # end each_statement

        new_object
      end
    end

    # Factory method to instantiate a Resource from URI
    def self.new_from_uri(uri)
      klasses = ActiveTriples::Resource.descendants.select(&:name)

      klasses.each do |klass|
        if uri.to_s.include? klass.base_uri.to_s
          object_id = uri.to_s.match(/[0-9a-fA-F]{24}/).to_s

          return klass.parent.find(object_id) if klass.parent.where(id: object_id).exists?
        end
      end

      nil
    end

  end
end
