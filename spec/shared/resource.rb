shared_context 'with data' do
  before do
    klass.configure type: RDF::DC.BibliographicResource

    klass.property :title,      predicate: RDF::DC.title,          # localized String
                                localize: true
    klass.property :alt,        predicate: RDF::DC.alternative,    # non-localized String
                                localize: false
    klass.property :references, predicate: RDF::DC.references      # URI
    klass.property :referenced, predicate: RDF::DC.isReferencedBy  # Array
    klass.property :is_valid,   predicate: RDF::DC.valid           # Boolean
    klass.property :date,       predicate: RDF::DC.date            # Date
    klass.property :issued,     predicate: RDF::DC.issued          # DateTime
    klass.property :spatial,    predicate: RDF::DC.spatial         # Float
    # klass.property :conformsTo, predicate: RDF::DC.conformsTo      # Hash
    klass.property :identifier, predicate: RDF::DC.identifier      # Integer
    # klass.property :license,    predicate: RDF::DC.license         # Range
    klass.property :source,     predicate: RDF::DC.source          # Symbol
    klass.property :created,    predicate: RDF::DC.created         # Time
  end

  attrs_hash = {
    title: 'Comet in Moominland',       # localized String
    alt: 'Mumintrollet pa kometjakt',   # non-localized String
    references: 'http://foo.com',       # URI
    referenced: %w(something another),  # Array
    is_valid: true,                     # Boolean -> xsd:boolean
    date: Date.new(1946),               # Date -> xsd:date
    issued: DateTime.new(1951),         # DateTime -> xsd:date
    spatial: 12.345,                    # Float -> xsd:double
    # conformsTo: { 'key' => 'value' }, # Hash
    identifier: 16_589_991,             # Integer -> xsd:integer
    # license: 1..10,                   # Range
    source: :something,                 # Symbol -> xsd:token
    created: Time.new.beginning_of_hour # Time
  }

  let(:subject) { klass.new(attrs_hash) }

  after do
    subject.title_translations = { 'en' => 'Comet in Moominland', # localized String
                                   'sv' => 'Kometen kommer' }
  end
end

shared_examples 'a Resource' do
  describe '#configure_model' do
    it 'should automatically have a base URI' do
      expect([RDF::URI('http://example.org/things/'),
              RDF::URI('http://example.org/subthings/')]).to include subject.rdf_subject.parent
    end

    # TODO: it should be registered in Ladder::Config
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
        expect(['Comet in Moominland', 'Kometen kommer']).to include(subject.title).or eq(subject.title)
      end

      it 'should return all locales' do
        expect('en' => 'Comet in Moominland', 'sv' => 'Kometen kommer').to include(subject.attributes['title']).or eq(subject.attributes['title'])
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

  describe '#rdf_label' do
    it 'should return the default label' do
      expect(['Comet in Moominland', 'Kometen kommer']).to include subject.rdf_label.first
    end
  end

  context 'a serializable' do
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

    describe '#as_qname' do
      it 'should output a valid qname representation of itself' do
        # TODO: check rdfs:label
      end
    end
  end

  describe '#new_from_graph' do
    before do
      subject.update_resource
    end

    let(:new_subject)  { klass.new_from_graph subject.resource }

    it 'should create a new object of the same class' do
      expect(new_subject.class).to eq subject.class
    end

    it 'should populate the same properties' do
      def remove_ids(hash)
        hash.delete '@id'
        hash.each_value { |value| remove_ids(value) if value.is_a? Hash }
      end

      expect(remove_ids(new_subject.as_framed_jsonld)).to eq remove_ids(subject.as_framed_jsonld)
    end
  end
end

shared_examples 'a Resource with relations' do
  describe 'serializable' do

    describe '#as_jsonld' do
      it 'should output a valid jsonld representation of itself and related' do
        graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
        expect(subject.update_resource.to_hash).to eq graph.to_hash
      end
    end

    describe '#as_qname' do
      it 'should output a valid qname representation of itself and related' do
        # TODO
      end
    end

    describe '#as_framed_jsonld' do
      it 'should output a valid framed jsonld representation of itself and related' do
        framed_graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_framed_jsonld)
        related_graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
        expect(framed_graph.to_hash).to eq related_graph.to_hash
      end
    end
  end

  it 'should have relations' do
    expect(subject.people.to_a).to include person
    expect(subject.concepts.to_a).to include concept
    expect(subject.part).to eq part
  end

  it 'should have inverse relations' do
    expect(person.things.to_a).to include subject
    expect(concept.relations).to be_empty
    expect(part.thing).to eq subject
  end

  describe 'with many-to-many' do
    it 'should have a relation' do
      expect(subject.relations['people'].relation).to eq Mongoid::Relations::Referenced::ManyToMany
      expect(subject.people.to_a).to include person
    end

    it 'should have an inverse relation' do
      expect(person.relations['things'].relation).to eq Mongoid::Relations::Referenced::ManyToMany
      expect(person.things.to_a).to include subject
    end

    it 'should have a valid predicate' do
      expect(subject.class.properties['people'].predicate).to eq RDF::DC.creator
    end

    it 'should have a valid inverse predicate' do
      expect(person.class.properties['things'].predicate).to eq RDF::DC.relation
    end
  end

  describe 'with one-sided has-many' do
    it 'should have a relation' do
      expect(subject.relations['concepts'].relation).to eq Mongoid::Relations::Referenced::ManyToMany
      expect(subject.concepts.to_a).to include concept
    end

    it 'should not have an inverse relation' do
      expect(subject.relations['concepts'].inverse_of).to be nil
      expect(concept.relations).to be_empty
    end

    it 'should have a valid predicate' do
      expect(subject.class.properties['concepts'].predicate).to eq RDF::DC.subject
    end

    it 'should not have an inverse predicate' do
      expect(concept.class.properties).to be_empty
    end
  end

  describe 'with embedded-one' do
    it 'should have a relation' do
      expect(subject.relations['part'].relation).to eq Mongoid::Relations::Embedded::One
      expect(subject.part).to eq part
    end

    it 'should have an inverse relation' do
      expect(part.relations['thing'].relation).to eq Mongoid::Relations::Embedded::In
      expect(part.thing).to eq subject
    end

    it 'should have a valid predicate' do
      expect(subject.class.properties['part'].predicate).to eq RDF::DC.hasPart
    end

    it 'should have a valid inverse predicate' do
      expect(part.class.properties['thing'].predicate).to eq RDF::DC.isPartOf
    end
  end

  describe '#update_resource with related' do
    # TODO: add tests for autosaved relations
    before do
      subject.update_resource
    end

    it 'should have a (non-localized?) literal object' do
      query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.title)
      expect(['Comet in Moominland', 'Kometen kommer']).to include query.first_object.to_s
    end

    it 'should have a localized literal object' do
      query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.alternative)
      expect('Mumintrollet pa kometjakt').to eq query.first_object.to_s
    end

    it 'should have an embedded object' do
      query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.hasPart)
      expect(query.count).to eq 1
      expect(query.first_object).to eq part.rdf_subject
    end

    it 'should have an embedded object relation' do
      query = subject.resource.query(subject: part.rdf_subject, predicate: RDF::DC.isPartOf)
      expect(query.count).to eq 1
      expect(query.first_object).to eq subject.rdf_subject
    end

    it 'should have related objects' do
      # many-to-many
      query_creator = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.creator)
      expect(query_creator.count).to eq 1
      expect(query_creator.first_object).to eq person.rdf_subject

      # one-sided has-many
      query_subject = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.subject)
      expect(query_subject.count).to eq 1
      expect(query_subject.first_object).to eq concept.rdf_subject

      # embedded-one
      query_part = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.hasPart)
      expect(query_part.count).to eq 1
      expect(query_part.first_object).to eq part.rdf_subject
    end

    it 'should have related object relations' do
      # many-to-many
      query = person.resource.query(subject: person.rdf_subject, predicate: RDF::DC.relation)
      expect(query.count).to eq 1
      expect(query.first_object).to eq subject.rdf_subject

      # one-sided has-many
      expect(concept.resource.query(object: subject.rdf_subject)).to be_empty

      # embedded-one
      query = part.resource.query(subject: part.rdf_subject, predicate: RDF::DC.isPartOf)
      expect(query.count).to eq 1
      expect(query.first_object).to eq subject.rdf_subject
    end
  end
end
