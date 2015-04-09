shared_examples 'a Serializable' do
  describe '#as_turtle' do
    it 'should output a valid turtle representation of itself' do
      graph = RDF::Graph.new << RDF::Turtle::Reader.new(subject.as_turtle)
      expect(subject.update_resource.to_hash).to eq graph.to_hash
    end
  end

  describe '#as_jsonld' do
    it 'should output a valid jsonld representation of itself' do
      graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
      expect(subject.update_resource.to_hash).to eq graph.to_hash
    end
  end

  describe '#as_framed_jsonld' do
    it 'should output a valid framed jsonld representation of itself and related' do
      framed_graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_framed_jsonld)
      related_graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
      expect(framed_graph.to_hash).to eq related_graph.to_hash
    end
  end

  describe '#as_qname' do
    it 'should output a valid qname representation of itself' do
      # TODO: check rdfs:label
    end
  end
end
