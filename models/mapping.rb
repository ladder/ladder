class Mapping
  include Mongoid::Document

  field :content_type, type: String  # A registered MIME-type for this mapping
  field :objects,      type: Hash    # A key-based list of objects in this mapping

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

        qname = RDF::URI(subject).qname

        next if qname.nil?# if qname is nil, we don't know this subject

        p "['#{qname.join(':')}', '#{value}', '#{target}'],"
      end
      
    end
    
    nil
  end

end