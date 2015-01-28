shared_examples 'a Resource' do

  describe 'LADDER_BASE_URI' do
    it 'should automatically have a base URI' do
      expect(subject.rdf_subject.parent).to eq RDF::URI('http://example.org/things/')
    end
  end

  describe '#property' do
    context 'with non-localized literal' do
      it 'should return non-localized value' do
        expect(subject.alt).to eq 'Mumintrollet pa kometjakt'
      end
      
      it 'should not be a localized hash' do
        expect(subject.attributes['alt']).to eq 'Mumintrollet pa kometjakt'
      end
      
      it 'should have a valid predicate' do
        expect(subject.class.properties['alt'].predicate).to eq RDF::DC.alternative
      end

      it 'allows resetting of properties' do
        subject.class.property :alt, predicate: RDF::DC.title
        expect(subject.class.properties['alt'].predicate).to eq RDF::DC.title
      end
    end
    
    context 'with localized literal' do
      it 'should return localized value' do
        expect(subject.title).to eq 'Comet in Moominland'
      end
      
      it 'should return all locales' do
        expect(subject.attributes['title']).to eq({'en' => 'Comet in Moominland'})
      end
      
      it 'should have a valid predicate' do
        expect(subject.class.properties['title'].predicate).to eq RDF::DC.title
      end

      it 'allows resetting of properties' do
        subject.class.property :title, predicate: RDF::DC.alternative
        expect(subject.class.properties['title'].predicate).to eq RDF::DC.alternative
      end
    end
  end

  describe '#update_resource' do
    before do
      subject.update_resource
    end

    it 'should have a non-localized literal object' do
      subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.title).each_statement do |s|
        expect(s.object.to_s).to eq 'Comet in Moominland'
      end
    end
    
    it 'should have a localized literal object' do
      subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.alternative).each_statement do |s|
        expect(s.object.to_s).to eq 'Mumintrollet pa kometjakt'
      end
    end

    it 'should not have related objects' do
      expect(subject.resource.query(object: subject)).to be_empty
    end
  end

  describe '#<<' do
    context 'with defined field' do
      before do
        subject << RDF::Statement(nil, RDF::DC.title, 'Kometen kommer')
      end
    
      it 'should update existing values' do
        expect(subject.title).to eq 'Kometen kommer'
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
#        expect(subject.type.count).to eq 1
        expect(subject.type).to include RDF::DC.BibliographicResource
      end
    end

    context 'with a URI value' do
      before do
        subject.class.property :identifier, predicate: RDF::DC.identifier
        subject << RDF::Statement(nil, RDF::DC.identifier, RDF::URI('http://some.uri'))
      end
    
      it 'should store the URI as a string' do
        expect(subject.identifier).to eq 'http://some.uri'
      end

      it 'should cast a URI into the resource' do
        subject.update_resource
        query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.identifier)
        expect(query.first_object).to be_a_kind_of RDF::URI
      end
    end
  end

  describe '#rdf_label' do
    it 'should return the default label' do
      expect(subject.rdf_label.to_a).to eq ['Comet in Moominland']
    end
  end

  context 'a serializable' do

    describe '#as_jsonld' do
      it 'should output a valid jsonld representation of itself' do
        graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
        expect(subject.update_resource.to_hash).to eq graph.to_hash
      end
    end

    describe '#as_qname' do
      it 'should output a valid qname representation of itself' do
        # TODO
      end
    end

  end

  describe '#new_from_graph' do
    before do
      subject.update_resource(related: true)
    end

    let(:new_subject)  { subject.class.new_from_graph subject.resource }
    
    it 'should create a new object of the same class' do
      expect(new_subject.class).to eq subject.class
    end
    
    it 'should populate the same properties' do
      expect(new_subject.as_framed_jsonld.except('@id')).to eq subject.as_framed_jsonld.except('@id')
    end
    
  end

end