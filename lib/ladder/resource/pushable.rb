module Ladder
  module Resource
    module Pushable
      ##
      # Push an RDF::Statement into the object
      #
      # @param [RDF::Statement, Hash, Array] statement @see RDF::Statement#from
      # @return [Object, nil] the value inserted into the object
      def <<(statement)
        # ActiveTriples::Resource expects: RDF::Statement, Hash, or Array
        statement = RDF::Statement.from(statement) unless statement.is_a? RDF::Statement

        # TODO: set of guards
        # - predicate must be defined
        # - subject OR object must be the object's rdf_subject

        # Only push statement if the statement's predicate is defined on the class
        field_name = field_from_predicate(statement.predicate)
        return unless field_name

        # FIXME
        objects = statement.object.is_a?(RDF::Node) && block_given? ? yield : statement.object

        update_field(field_name, *objects) if fields[field_name] # statement.object
        update_relation(field_name, *objects) if relations[field_name] # RDF::Node / block
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

      ##
      # Set values on a field; this will cast values
      # from RDF types to persistable Mongoid types
      #
      # @param [String] field_name ActiveModel attribute name for the field
      # @param [Array<Object>] obj objects (usually RDF::Terms) to be set
      # @return [Object, nil]
      def update_field(field_name, *obj)
        # Should be an Array of RDF::Term objects
        return unless obj

        if fields[field_name] && fields[field_name].localized?
          trans = {}

          obj.each do |item|
            lang = item.is_a?(RDF::Literal) && item.has_language? ? item.language.to_s : I18n.locale.to_s
            value = item.is_a?(RDF::URI) ? item.to_s : item.object # TODO: tidy this up
            trans[lang] = trans[lang] ? [*trans[lang]] << value : value
          end

          send("#{field_name}_translations=", trans) unless trans.empty?
        else
          objects = obj.map { |item| item.is_a?(RDF::URI) ? item.to_s : item.object } # TODO: tidy this up
          send("#{field_name}=", objects.size > 1 ? objects : objects.first)
        end
      end

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

    end
  end
end
