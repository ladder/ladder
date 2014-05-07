class Mapping
  include Mongoid::Document

  field :content_type, :type => String # A registered MIME-type
  field :model, :type => String # A Ladder::Model class

  field :types, :type => Array  # A list of RDF::Vocabulary class properties
  field :properties, :type => Array  # A list of RDF::Vocabulary property / XPath pairs

  # recursively_embeds_many

  # FIXME: TEMPORARY FOR DEBUGGING
  def self.test
    hash = JSON.parse File.read('lib/ladder/mapping.jsonld')
    graph = ::RDF::Graph.new << JSON::LD::API.toRdf(hash)
  end

  # Take an RDF::Graph and create a Mapping instance from it
  def self.new_from_rdf(graph)
    return unless graph.valid?

=begin
    # consider iterating over graph.to_hash

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