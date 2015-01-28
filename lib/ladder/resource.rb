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

      resource.set_value(property.predicate, value) #if value
    end

    resource
  end

  ##
  # Push RDF statement into resource
  def <<(data)
    # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
    data = RDF::Statement.from(data) unless data.is_a? RDF::Statement

    # Only push statement if the statement's predicate is defined on the class
    if resource_class.properties.values.map(&:predicate).include? data.predicate
      field_name = resource_class.properties.select { |name, term| term.predicate == data.predicate }.keys.first

      # If the object is a URI for a model object, retrieve the object
      if rel = relations[field_name] and data.object.is_a? RDF::URI
        # FIXME: this fails on embedded objects because they can't be found with #find
#binding.pry if 'part' == field_name
        return unless object_id    = data.object.to_s.match(/[0-9a-fA-F]{24}/)
        return unless object_model = rel.class_name.constantize.find(object_id.to_s) rescue nil

        # TODO: clean this logic up if possible
        if rel.relation.ancestors.include? Mongoid::Relations::Many
          self.send("#{field_name}").send("<<", object_model)
        else
          self.send("#{field_name}=", object_model)
        end
      else
        self.send("#{field_name}=", data.object.to_s)
      end
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
        self.send(name)
      end
    end
    
    def update_from_relation(name, opts = {})
      objects = self.send(name).to_a

      if opts[:related] or embedded_relations[name]
        # Force autosave of related documents to ensure correct serialization
        methods.select{|i| i[/autosave_documents/] }.each{|m| send m}

        # update inverse relation properties
        relation_def = relations[name]
        objects.each { |object| object.resource.set_value(relation_def.inverse, self.rdf_subject) } if relation_def.inverse
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
    def property(name, opts={})
      if class_name = opts[:class_name]
        mongoid_opts = {autosave: true, index: true}.merge(opts.except(:predicate, :multivalue))
        opts.except! *mongoid_opts.keys

        has_and_belongs_to_many(name, mongoid_opts) unless relations.keys.include? name.to_s
      else
        field(name, localize: true) unless fields[name.to_s]
      end

      super
    end

    def new_from_graph(graph)
      # Get the first object in the graph with the same RDF type as this class
      return unless subject_uri = graph.query([nil, RDF.type, resource_class.type]).first_subject

      new_object = self.new
      graph.query([subject_uri]).each_statement do |statement|
#binding.pry if statement.object.is_a? RDF::URI
        new_object << statement
      end

      new_object
    end

  end

end