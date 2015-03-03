shared_context 'with data' do
  before do
    subject.alt = 'Mumintrollet pa kometjakt' # non-localized literal
    subject.title = 'Comet in Moominland'     # localized literal
  end
end

shared_examples 'a Dynamic Resource' do
  describe '#property' do
    context 'with undefined property' do
      before do
        subject.property :description, predicate: RDF::DC.description
        subject.description = "Second in Tove Jansson's series of Moomin books"
      end

      it 'should create a context' do
        expect(subject._context).to eq(description: RDF::DC.description.to_uri.to_s)
      end

      it 'should build an accessor' do
        expect(subject.description).to eq "Second in Tove Jansson's series of Moomin books"
      end
    end

    context 'with conflicting property' do
      before do
        subject.property :title, predicate: RDF::DC11.title
        subject.dc11_title = 'Kometjakten'
      end

      it 'should create a context' do
        expect(subject._context).to eq(dc11_title: RDF::DC11.title.to_uri.to_s)
      end

      it 'should build an accessor' do
        expect(subject.dc11_title).to eq 'Kometjakten'
      end
    end
  end

  describe '#update_resource' do
    before do
      # undefined property
      subject.property :description, predicate: RDF::DC.description
      subject.description = "Second in Tove Jansson's series of Moomin books"

      # conflicting property
      subject.property :title, predicate: RDF::DC11.title
      subject.dc11_title = 'Kometjakten'

      # defined field
      subject << RDF::Statement(nil, RDF::DC.title, 'Kometen kommer')

      # conflicting property
      subject << RDF::Statement(nil, RDF::DC.alternative, 'Kometjakten')

      # URI value
      subject << RDF::Statement(nil, RDF::DC.identifier, RDF::URI('http://some.uri'))

      # RDF type
      subject << RDF::Statement(nil, RDF.type, RDF::DC.PhysicalResource)

      subject.update_resource
    end

    it 'should have updated values' do
      expect(subject.resource.statements.count).to eq 7
      expect(subject.resource.query(predicate: RDF::DC.description, object: "Second in Tove Jansson's series of Moomin books").count).to eq 1
      expect(subject.resource.query(predicate: RDF::DC11.title, object: 'Kometjakten').count).to eq 1
      expect(subject.resource.query(predicate: RDF::DC.title, object: RDF::Literal.new('Kometen kommer', language: :en)).count).to eq 1
      expect(subject.resource.query(predicate: RDF::DC.alternative, object: 'Kometjakten').count).to eq 1
      expect(subject.resource.query(predicate: RDF::DC.identifier, object: RDF::URI('http://some.uri')).count).to eq 1
    end

    it 'should contain both class and dynamic types' do
      expect(subject.type.count).to eq 2
      expect(subject.type).to include RDF::DC.BibliographicResource
      expect(subject.type).to include RDF::DC.PhysicalResource
    end
  end

  describe '#<<' do
    context 'with defined field' do
      before do
        subject << RDF::Statement(nil, RDF::DC.title, 'Kometen kommer')
      end

      it 'should not create a context' do
        expect(subject._context).to be nil
      end

      it 'should update existing values' do
        expect(subject.title).to eq 'Kometen kommer'
      end
    end

    context 'with undefined field' do
      before do
        subject << RDF::Statement(nil, RDF::DC.description, "Second in Tove Jansson's series of Moomin books")
      end

      it 'should create a context' do
        expect(subject._context).to eq(description: RDF::DC.description.to_uri.to_s)
      end

      it 'should build an accessor' do
        expect(subject.description).to eq "Second in Tove Jansson's series of Moomin books"
      end
    end

    context 'with conflicting property' do
      before do
        subject << RDF::Statement(nil, RDF::DC11.title, 'Kometjakten')
      end

      it 'should create a context' do
        expect(subject._context).to eq(dc11_title: RDF::DC11.title.to_uri.to_s)
      end

      it 'should build an accessor' do
        expect(subject.dc11_title).to eq 'Kometjakten'
      end
    end

    context 'with a URI value' do
      before do
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

  describe '#resource_class' do
    before do
      subject.property :description, predicate: RDF::DC.description
    end

    it 'should have modified properties on the instance' do
      expect(subject.resource.class.properties.keys).to include 'description'
    end

    it 'should not modify the global class properties' do
      expect(subject.class.resource_class.properties.keys).to_not include 'description'
      expect(subject.class.resource_class.properties).to eq subject.class.new.class.resource_class.properties
    end
  end
end

shared_examples 'a Resource' do
  describe 'LADDER_BASE_URI' do
    it 'should automatically have a base URI' do
      expect(subject.resource.rdf_subject.parent).to eq RDF::URI.new(LADDER_BASE_URI) / subject.class.name.underscore.pluralize + '/'
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
        expect(subject.attributes['title']).to eq('en' => 'Comet in Moominland')
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
        # expect(subject.type.count).to eq 1
        expect(subject.type).to include RDF::DC.BibliographicResource
      end
    end

    context 'with a URI value' do
      before do
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
        # TODO: check rdfs:label
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
      # TODO: clean this up
      def remove_ids(x)
        if x.is_a?(Hash)
          x.reduce({}) do |m, (k, v)|
            m[k] = remove_ids(v) unless k == '@id'
            m
          end
        else
          x
        end
      end

      expect(remove_ids(new_subject.as_framed_jsonld)).to eq remove_ids(subject.as_framed_jsonld)
    end
  end
end

shared_examples 'a Resource with relations' do
  describe 'serializable' do
    # TODO: contexts with relations and without
    # expect(subject.as_jsonld(related: true)).to eq subject.as_jsonld
    # expect(subject.as_qname(related: true)).to eq subject.as_qname
    # expect(subject.as_framed_jsonld).to eq subject.as_jsonld

    describe '#as_jsonld related: true' do
      it 'should output a valid jsonld representation of itself and related' do
        graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld related: true)
        expect(subject.update_resource(related: true).to_hash).to eq graph.to_hash
      end
    end

    describe '#as_qname related: true' do
      it 'should output a valid qname representation of itself and related' do
        # TODO
      end
    end

    describe '#as_framed_jsonld' do
      it 'should output a valid framed jsonld representation of itself and related' do
        framed_graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_framed_jsonld)
        related_graph = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld related: true)
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
      expect(part.class.properties['thing'].predicate).to eq RDF::DC.relation
    end
  end

  describe '#update_resource with related' do
    # TODO: add tests for autosaved relations
    before do
      subject.update_resource(related: true)
    end

    it 'should have a literal object' do
      query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.title)
      expect(query.first_object.to_s).to eq 'Comet in Moominland'
    end

    it 'should have an embedded object' do
      query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.hasPart)
      expect(query.count).to eq 1
      expect(query.first_object).to eq part.rdf_subject
    end

    it 'should have an embedded object relation' do
      query = subject.resource.query(subject: part.rdf_subject, predicate: RDF::DC.relation)
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
      query = part.resource.query(subject: part.rdf_subject, predicate: RDF::DC.relation)
      expect(query.count).to eq 1
      expect(query.first_object).to eq subject.rdf_subject
    end
  end

  describe '#update_resource with related and then without related' do
    # TODO: add tests for autosaved relations
    before do
      subject.update_resource(related: true)
      subject.update_resource # implicit false
    end

    it 'should not have related objects' do
      expect(subject.resource.query(subject: person.rdf_subject)).to be_empty
      expect(subject.resource.query(subject: concept.rdf_subject)).to be_empty
    end

    it 'should have embedded object relations' do
      query = subject.resource.query(subject: part.rdf_subject, predicate: RDF::DC.relation)
      expect(query.count).to eq 1
      expect(query.first_object).to eq subject.rdf_subject
    end

    it 'should have related object relations' do
      # many-to-many
      query = person.resource.query(subject: person.rdf_subject, predicate: RDF::DC.relation)
      expect(query.count).to eq 1
      expect(query.first_object).to eq subject.rdf_subject

      # one-sided has-many
      expect(concept.resource.query(object: subject.rdf_subject)).to be_empty

      # embedded-one
      query = part.resource.query(subject: part.rdf_subject, predicate: RDF::DC.relation)
      expect(query.count).to eq 1
      expect(query.first_object).to eq subject.rdf_subject
    end
  end
end
