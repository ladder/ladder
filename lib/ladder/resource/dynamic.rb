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
      # Dynamic field definition
      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def property(field_name, *opts)
        # Store context information
        self._context ||= Hash.new(nil)

        # Ensure new field name is unique
        if resource_class.properties.symbolize_keys.keys.include? field_name
          field_name = opts.first[:predicate].qname.join('_').to_sym
        end

        self._context[field_name] = opts.first[:predicate].to_s
        apply_context
      end

      private

      ##
      # Dynamic field accessors (Mongoid)
      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
      def create_accessors(field_name)
        define_singleton_method(field_name) { read_attribute(field_name) }
        define_singleton_method("#{field_name}=") { |value| write_attribute(field_name, value) }
      end

      ##
      # Apply dynamic fields and properties to this instance
      #
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
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
      # TODO: documentation
      # @param [Type] name1 more information
      # @param [Type] name2 more information
      # @return [Type, nil] describe return value(s)
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
        # Overload Ladder #update_resource
        #
        # @see Ladder::Resource
        #
        # TODO: documentation
        # @param [Type] name1 more information
        # @param [Type] name2 more information
        # @return [Type, nil] describe return value(s)
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
        # Overload Ladder #<<
        #
        # @see Ladder::Resource
        #
        # TODO: documentation
        # @param [Type] name1 more information
        # @param [Type] name2 more information
        # @return [Type, nil] describe return value(s)
        def <<(data)
          # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
          data = RDF::Statement.from(data) unless data.is_a? RDF::Statement

          if RDF.type == data.predicate
            # Store type information
            self._types ||= []
            self._types << data.object.to_s

            apply_types
            return
          end

          # If we have an undefined predicate, then dynamically define it
          property data.predicate.qname.last, predicate: data.predicate unless field_from_predicate data.predicate

          super
        end

        private

        ##
        # Overload ActiveTriples #resource_class
        #
        # @see ActiveTriples::Identifiable
        #
        # TODO: documentation
        # @param [Type] name1 more information
        # @param [Type] name2 more information
        # @return [Type, nil] describe return value(s)
        def resource_class
          @modified_resource_class ||= self.class.resource_class.clone
        end
      end
    end
  end
end
