module Ladder
  module Resource
    module Dynamic
      extend ActiveSupport::Concern

      include Ladder::Resource

      included do
        include InstanceMethods

        field :_context, type: Hash
        field :_types,   type: Array

        after_find :apply_context
        after_find :apply_types
      end

      ##
      # Dynamically define a field on the object instance; in addition to
      # (or overloading) class-level properties
      #
      # @see Ladder::Resource#property
      #
      # @param [String] field_name ActiveModel attribute name for the field
      # @param [Hash] opts options to pass to Mongoid / ActiveTriples
      # @return [Hash] an updated context for the object
      def property(field_name, opts = {})
        # Store context information
        self._context ||= Hash.new(nil)

        # Ensure new field name is unique
        field_name = opts[:predicate].qname.join('_').to_sym if resource_class.properties.symbolize_keys.keys.include? field_name

        self._context[field_name] = opts[:predicate].to_s
        apply_context
      end

      private

      ##
      # Dynamically define field accessors
      #
      # @see http://mongoid.org/en/mongoid/v3/documents.html#dynamic_fields Mongoid Dynamic Fields
      #
      # @param [String] field_name ActiveModel attribute name for the field
      # @return [void]
      def create_accessors(field_name)
        define_singleton_method(field_name) { read_attribute(field_name) }
        define_singleton_method("#{field_name}=") { |value| write_attribute(field_name, value) }
      end

      ##
      # Apply dynamic fields and properties to this instance
      #
      # @return [void]
      def apply_context
        return unless self._context

        self._context.each do |field_name, uri|
          next if fields.keys.include? field_name

          if RDF::Vocabulary.find_term(uri)
            create_accessors field_name

            # Update resource properties
            resource_class.property(field_name.to_sym, predicate: RDF::Vocabulary.find_term(uri))
          end
        end
      end

      ##
      # Apply dynamic types to this instance
      #
      # @return [void]
      def apply_types
        return unless _types

        _types.each do |rdf_type|
          unless resource.type.include? RDF::Vocabulary.find_term(rdf_type)
            resource << RDF::Statement.new(rdf_subject, RDF.type, RDF::Vocabulary.find_term(rdf_type))
          end
        end
      end

      module InstanceMethods
        ##
        # Update the delegated ActiveTriples::Resource from
        # ActiveModel properties & relations
        #
        # @see Ladder::Resource#update_resource
        #
        # @param [Hash] opts options to pass to Mongoid / ActiveTriples
        # @return [ActiveTriples::Resource] resource for the object
        def update_resource(opts = {})
          # NB: super has to go first or AT clobbers properties
          super(opts)

          if self._context
            self._context.each do |field_name, uri|
              value = send(field_name)
              cast_uri = RDF::URI.new(value)
              resource.set_value(RDF::Vocabulary.find_term(uri), cast_uri.valid? ? cast_uri : value)
            end
          end

          resource
        end

        ##
        # Push an RDF::Statement into the object
        #
        # @see Ladder::Resource#<<
        #
        # @param [RDF::Statement, Hash, Array] statement @see RDF::Statement#from
        # @return [void]
        def <<(statement)
          # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
          statement = RDF::Statement.from(statement) unless statement.is_a? RDF::Statement

          # Don't store statically-defined types
          return if resource_class.type == statement.object

          if RDF.type == statement.predicate
            # Store type information
            self._types ||= []
            self._types << statement.object.to_s

            apply_types
            return
          end

          # If we have an undefined predicate, then dynamically define it
          return unless statement.predicate.qname
          property statement.predicate.qname.last, predicate: statement.predicate unless field_from_predicate statement.predicate

          super
        end

        private

        ##
        # Return a cloned, mutatable copy of the
        # ActiveTriples::Resource class for this instance
        #
        # @see ActiveTriples::Identifiable#resource_class
        #
        # @return [Class] a GeneratedResourceSchema for this class
        def resource_class
          @modified_resource_class ||= self.class.resource_class.clone
        end
      end
    end
  end
end
