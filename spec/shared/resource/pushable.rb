shared_examples 'a Pushable' do
  describe '#<<' do
    context 'with defined field' do
      before do
        subject << RDF::Statement(nil, RDF::DC.title, RDF::Literal.new('Kometen kommer', language: :sv))
      end

      it 'should update existing values' do
        expect(subject.title_translations).to eq('sv' => 'Kometen kommer')
      end
    end

    context 'with undefined field' do
      before do
        subject << RDF::Statement(nil, RDF::DC.description, "Second in Tove Jansson's series of Moomin books")
      end

      it 'should ignore undefined properties' do
        expect(subject.fields['description']).to be_nil
        expect(subject.resource.query(predicate: RDF::DC.description)).to be_empty
      end
    end

    context 'with a RDF type' do
      before do
        subject << RDF::Statement(nil, RDF.type, RDF::DC.PhysicalResource)
      end

      it 'should only contain types defined on the class' do
        # expect(subject.type.count).to eq 1
        expect(subject.type).to include RDF::DC.BibliographicResource
      end
    end

    context 'with a URI value' do
      before do
        subject << RDF::Statement(nil, RDF::DC.references, RDF::URI('http://some.uri'))
      end

      it 'should store the URI as a string' do
        expect(subject.references).to eq 'http://some.uri'
      end

      it 'should cast a URI into the resource' do
        subject.update_resource
        query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.references)
        expect(query.first_object).to be_a_kind_of RDF::URI
      end
    end
  end
end