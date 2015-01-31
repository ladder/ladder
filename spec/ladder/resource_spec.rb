require 'spec_helper'

describe Ladder::Resource do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI ||= 'http://example.org'

    class Thing
      include Ladder::Resource
      configure type: RDF::DC.BibliographicResource
    end
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Thing") if Object
  end

  shared_context 'with data' do
    before do
      subject.class.configure type: RDF::DC.BibliographicResource

      # non-localized literal
      subject.class.field :alt
      subject.class.property :alt, predicate: RDF::DC.alternative
      subject.alt = 'Mumintrollet pa kometjakt'

      # localized literal
      subject.class.property :title, predicate: RDF::DC.title
      subject.title = 'Comet in Moominland'
    end
  end

  shared_context 'with relations' do
    let(:person)  { Person.new }
    let(:concept) { Concept.new }
    let(:part)    { Part.new }
    
    before do
      class Person
        include Ladder::Resource
      end

      class Concept
        include Ladder::Resource
      end

      class Part
        include Ladder::Resource
      end

      person.class.configure type: RDF::DC.AgentClass
      concept.class.configure type: RDF::SKOS.Concept
      part.class.configure type: RDF::DC.PhysicalResource

      # many-to-many
      person.class.property :things, predicate: RDF::DC.relation, class_name: 'Thing'
      subject.class.property :people, predicate: RDF::DC.creator, class_name: 'Person'
      subject.people << person

      # one-sided has-many
      subject.class.has_and_belongs_to_many :concepts, inverse_of: nil, autosave: true
      subject.class.property :concepts, predicate: RDF::DC.subject, class_name: 'Concept'
      subject.concepts << concept

      # embedded one
      part.class.embedded_in :thing
      part.class.property :thing, predicate: RDF::DC.relation, class_name: 'Thing'
      subject.class.embeds_one :part, cascade_callbacks: true
      subject.class.property :part, predicate: RDF::DC.hasPart, class_name: 'Part'
      subject.part = part
      subject.save
    end

    after do
      Object.send(:remove_const, "Person") if Object
      Object.send(:remove_const, 'Concept') if Object
      Object.send(:remove_const, 'Part') if Object
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
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(subject.people.to_a).to include person
      end

      it 'should have an inverse relation' do
        expect(person.relations['things'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
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
        expect(subject.relations['concepts'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
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
        expect(subject.relations['part'].relation).to eq (Mongoid::Relations::Embedded::One)
        expect(subject.part).to eq part
      end

      it 'should have an inverse relation' do
        expect(part.relations['thing'].relation).to eq (Mongoid::Relations::Embedded::In)
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
      # TODO add tests for autosaved relations
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
      # TODO add tests for autosaved relations
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

    context 'serializable' do
      # TODO: contexts with relations and without
#      expect(subject.as_jsonld(related: true)).to eq subject.as_jsonld
#      expect(subject.as_qname(related: true)).to eq subject.as_qname
#      expect(subject.as_framed_jsonld).to eq subject.as_jsonld

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

  end

  context 'with data' do
    let(:subject) { Thing.new }

    include_context 'with data'

    it_behaves_like 'a Resource'
  end

  context 'with relations' do
    let(:subject) { Thing.new }

    include_context 'with data'
    include_context 'with relations'

    it_behaves_like 'a Resource'
  end
  
  context 'from JSON-LD' do
    require 'modsrdf'

    TEST_FILE ||= './spec/shared/modsrdf.jsonld'

    let(:subject) { Thing.new }
    let(:source) { open(TEST_FILE).read }

    before do
      class Genre
        include Ladder::Resource#::Dynamic
        configure type: RDF::LC::MADS.GenreForm
      end

      subject.class.configure type: RDF::LC::MODS.ModsResource
      subject.class.property :genre, predicate: RDF::LC::MODS.genre, class_name: 'Genre'
    end
    
    it 'should do something' do
      # TODO
      nfg = subject.class.new_from_graph RDF::Graph.load TEST_FILE
      binding.pry
    end

  end

end