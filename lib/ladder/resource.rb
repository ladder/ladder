require 'mongoid'
require 'active_triples'

module Ladder::Resource
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
    defined_prop = resource_class.properties.find { |name, term| term.predicate == statement.predicate }
    return unless defined_prop

    field_name = defined_prop.first

    # If the object is a URI for a model object, retrieve the object
    if statement.object.is_a? RDF::URI
      object_id = statement.object.to_s.match(/[0-9a-fA-F]{24}/)
      relation = relations[field_name]

      if object_id and relation
        # If this is an embedded object, we have to retrieve the parent
        # FIXME: this seems unlikely and/or hacky
        if embedded_relations[field_name]
          value = relation.inverse_class_name.constantize.where("#{field_name}._id" => BSON::ObjectId.from_string(object_id.to_s)).first.send(field_name) rescue nil
        else
          value = relation.class_name.constantize.find(object_id.to_s) rescue nil
        end
      end
    end

    value ||= statement.object.to_s
    value = yield(field_name) || value if block_given?

    if send(field_name).is_a? Enumerable
      send(:push, field_name.to_sym => value)
    else
      send("#{field_name}=", value)
    end
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

    def new_from_graph(graph)
      # Get the first object in the graph with the same RDF type as this class
      subject_id = graph.query([nil, RDF.type, resource_class.type]).first_subject
      return unless subject_id

      # TODO: if the subject is an existing model, just retrieve it?
      new_object = new

      graph.query([subject_id]).each_statement do |statement|

        # Objects can be one of:
        #
        # 1. BNode
        # 2. A URI
        #    a. Internal model
        #    b. External
        # 3. A literal
        #    a. Plain
        #    b. Language-typed

        if statement.object.is_a? RDF::Node
          new_object.send(:<<, statement) do |field_name|
            relation = relations[field_name]
            return unless relation

            klass = relation.class_name.constantize
            subgraph = RDF::Graph.new.insert graph.query([statement.object]).statements
            klass.new_from_graph subgraph
          end
        else
          new_object << statement
        end

      end # end each_statement

      new_object
    end
  end
end
