shared_examples 'a Serializable' do
  
  describe '#as_jsonld' do
    it 'should output a valid jsonld representation of itself' do
      # TODO: this isn't a valid test
      graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
      expect(subject.resource.to_hash).to eq graph.to_hash
    end
  end

  describe '#as_qname' do
    it 'should output a valid qname representation of itself' do
      # TODO
    end
  end

  context 'with related' do

    describe '#as_jsonld related: true' do
      it 'should output a valid jsonld representation of itself and related' do
        if subject.relations.empty?
          expect(subject.as_jsonld(related: true)).to eq subject.as_jsonld
        else
          graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld related: true)
        end
      end
    end

    describe '#as_qname related: true' do
      it 'should output a valid qname representation of itself and related' do
        if subject.relations.empty?
          expect(subject.as_qname(related: true)).to eq subject.as_qname
        else
          # TODO
        end
      end
    end

    describe '#as_framed_jsonld' do
      it 'should output a valid framed jsonld representation of itself and related' do
        if subject.relations.empty?
          expect(subject.as_framed_jsonld).to eq subject.as_jsonld
        else
          expect(subject.as_framed_jsonld['dc:creator']).to eq person.as_framed_jsonld.except '@context'
#          expect(person.as_framed_jsonld['dc:relation']).to eq subject.as_framed_jsonld.except '@context'
        end
      end
    end
  end
end