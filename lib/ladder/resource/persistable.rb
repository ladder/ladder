module Ladder
  module Resource
    module Persistable
      extend ActiveSupport::Concern

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

      module ClassMethods
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
            # Group statements for this predicate
            stmts = subgraph.query([root_subject, statement.predicate])

            if stmts.size > 1
              # We have already set this value in a prior pass
              next if new_object.read_attribute new_object.field_from_predicate statement.predicate

              # If there are multiple statements for this predicate, pass an array
              statement.object = RDF::Node.new
              new_object.send(:<<, statement) { stmts.objects.to_a } # TODO: implement #set_value instead

            elsif statement.object.is_a? RDF::Node
              next if objects[statement.object]

              # If the object is a BNode, dereference the relation
              objects[statement.object] = new_object.send(:<<, statement) do  # TODO: implement #set_value instead
                klass = new_object.klass_from_predicate(statement.predicate)
                klass.new_from_graph(graph, objects, [statement.object]) if klass
              end

            else new_object << statement
            end
          end # end each_statement

          new_object
        end
      end
    end
  end
end
