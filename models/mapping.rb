class Mapping
  include Mongoid::Document

  field :content_type, :type => String  # A registered MIME-type
  field :model, :type => String         # A Ladder::Model class

  field :properties, :type => Array     # A list of RDF::Vocabulary property / XPath pairs
#  field :mappings, :type => Array     # A list of related Mapping objects

  recursively_embeds_many store_as: 'mappings' # A list of related Mapping objects

  # FIXME: TEMPORARY FOR DEBUGGING
  def self.test
    hash = JSON.parse File.read('lib/ladder/mapping.jsonld')
    graph = ::RDF::Graph.new << JSON::LD::API.toRdf(hash)
  end

  # Take an RDF::Graph and create a Mapping instance from it
  def self.new_from_rdf(graph)
    return unless graph.valid?

    # consider iterating over graph.to_hash
    graph.to_hash.each do |object_node, predicates|
      p "OBJECT ID #{object_node}"
      
      predicates.each do |subject, object|
        # NB: object will be 1- or 2- element array
        case object.count

        when 2
          if object.first.is_a? RDF::Literal
            value = object.first
            target = object.last
          else
            value = object.last
            target = object.first
          end

        when 1
          if object.first.is_a? RDF::Literal
            value = object.first
          else
            target = object.first
          end
        end

        qname = RDF::URI(subject).qname || subject

        p "#{qname} : #{value} #{target}"
      end
      
      p ""
    end
    
    nil
=begin
    # NB: assuming the JSON-LD parser puts the root Subject first
    graph.each_subject do |subject|
      graph.query([subject, nil, nil]) do |statement|
        p statement.inspect
      end
    end

graph.each_statement { |s| p s.inspect }

    graph.each_triple do |subject, predicate, object|
      # NB: we assume the subject is the model being built
      # may consider handling subject URIs for eg. validation or implicit sameAs
    end
    # model = self.new
    # graph.select {|s, p, o| RDF.type == p}
    # types = graph.each_triple do |s, p, o|
    # end
=end
  end

end