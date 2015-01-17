shared_examples 'a Serializable Resource' do
  include_context 'with relations'
  
  describe '#as_jsonld' do
    it 'should output a valid jsonld representation of itself' do
      g = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
      expect(subject.resource.to_hash == g.to_hash).to be true
    end
  end
  
  describe '#as_jsonld related: true' do
    it 'should output a valid jsonld representation of itself and related' do
      # TODO
    end
  end
  
  describe '#as_qname' do
    it 'should output a valid qname representation of itself' do
      # TODO
    end
  end
  
  describe '#as_qname related: true' do
    it 'should output a valid qname representation of itself and related' do
      # TODO
    end
  end
  
  describe '#as_framed_jsonld' do
    before do
      # TODO: ensure subject, person, concept, part all have RDF types set
    end

    it 'should output a valid framed jsonld representation of itself and related' do
      g = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_framed_jsonld)
      # TODO
    end
  end
end
