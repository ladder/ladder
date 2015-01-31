module Ladder::Resource::Dynamic
  extend ActiveSupport::Concern

  included do
    include Ladder::Resource
    include InstanceMethods

    field :_context, type: Hash
    field :_types,   type: Array

    after_find :apply_context
    after_find :apply_types
  end

  ##
  # Dynamic field definition
  def property(field_name, *opts)
    # Store context information
    self._context ||= Hash.new(nil)

    # Ensure new field name is unique
    field_name = opts.first[:predicate].qname.join('_').to_sym if respond_to? field_name or :name == field_name
    self._context[field_name] = opts.first[:predicate].to_s

    apply_context
  end

  private

    ##
    # Dynamic field accessors (Mongoid)
    def create_accessors(field_name)
      define_singleton_method(field_name) { read_attribute(field_name) }
      define_singleton_method("#{field_name}=") { |value| write_attribute(field_name, value) } 
    end
    
    ##
    # Apply dynamic fields and properties to this instance
    def apply_context
      return unless self._context

      self._context.each do |field_name, uri|
        next if fields.keys.include? field_name

        if term = RDF::Vocabulary.find_term(uri)
          create_accessors field_name

          # Update resource properties
          resource_class.property(field_name.to_sym, predicate: term)
        end
      end
    end
    
    ##
    # Apply dynamic types to this instance
    def apply_types
      return unless self._types

      self._types.each do |rdf_type|
        unless resource.type.include? term = RDF::Vocabulary.find_term(rdf_type)
          resource << RDF::Statement.new(rdf_subject, RDF.type, term)
        end
      end
    end

  module InstanceMethods

    ##
    # Overload Ladder #update_resource
    #
    # @see Ladder::Resource
    def update_resource(opts = {})
      # NB: super has to go first or AT clobbers properties
      super(opts)

      if self._context
        self._context.each do |field_name, uri|
          value = self.send(field_name)
          cast_uri = RDF::URI.new(value)
          resource.set_value(RDF::Vocabulary.find_term(uri), cast_uri.valid? ? cast_uri : value)
        end
      end

      resource
    end

    ##
    # Overload Ladder #<<
    #
    # @see Ladder::Resource
    def <<(data, &block)
      # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
      data = RDF::Statement.from(data) unless data.is_a? RDF::Statement

      if RDF.type == data.predicate
        # Store type information
        self._types ||= Array.new
        self._types << data.object.to_s

        apply_types
        return
      end

      # If we have an undefined predicate, then dynamically defne it
      unless resource_class.properties.values.map(&:predicate).include? data.predicate
        # Generate a dynamic field name
        qname = data.predicate.qname
        field_name = (respond_to? qname.last or :name == qname.last) ? qname.join('_').to_sym : qname.last

        # Define property on object
        property field_name, predicate: data.predicate
      end

      super
    end

    private
      ##
      # Overload ActiveTriples #resource_class
      #
      # @see ActiveTriples::Identifiable
      def resource_class
        @modified_resource_class ||= self.class.resource_class.clone
      end

  end

end