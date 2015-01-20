require 'spec_helper'

describe Ladder::Resource do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI ||= 'http://example.org'

    class Thing
      include Ladder::Resource
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
      subject.class.has_and_belongs_to_many :concepts, inverse_of: nil
      subject.class.property :concepts, predicate: RDF::DC.subject, class_name: 'Concept'
      subject.concepts << concept

      # embedded one
      part.class.embedded_in :thing
      part.class.property :thing, predicate: RDF::DC.relation, class_name: 'Thing'
      subject.class.embeds_one :part, cascade_callbacks: true
      subject.class.property :part, predicate: RDF::DC.hasPart, class_name: 'Part'
      subject.part = part
      subject.save
      
      # embedded many
=begin
      subject.class.embeds_many :people
      subject.class.property :people, predicate: RDF::DC.creator, class_name: 'Person'

      person.class.embedded_in :thing
      person.class.property :thing, predicate: RDF::DC.relation, class_name: 'Thing'

      subject.people << person
=end
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

    context 'with many-to-many' do
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

    context 'with one-sided has-many' do
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

    context 'with embedded-one' do
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
    
    context '#update_resource with related' do
      before do
        subject.update_resource(related: true)
      end

      it 'should have a literal object' do
        subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.title).each_statement do |s|
          expect(s.object.to_s).to eq 'Comet in Moominland'
        end
      end

=begin
      it 'should have an embedded object' do
        query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.hasPart)
        expect(query.count).to eq 1
        
        query.each_statement do |s|
          expect(s.object).to eq part.rdf_subject
        end
      end

      it 'should have an embedded object relation' do
        query = subject.resource.query(subject: part.rdf_subject, predicate: RDF::DC.relation)
        expect(query.count).to eq 1
        expect(query.to_hash).to eq part.resource.statements.to_hash

        query.each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end

    it 'should have an embedded object' do
      query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.hasPart)
      expect(query.count).to eq 1
      
      query.each_statement do |s|
        expect(s.object).to eq part.rdf_subject
      end
    end

    it 'should have an embedded object relation' do
      query = subject.resource.query(subject: part.rdf_subject, predicate: RDF::DC.relation)
      expect(query.count).to eq 1
      expect(query.to_hash).to eq part.resource.statements.to_hash

      query.each_statement do |s|
        expect(s.object).to eq subject.rdf_subject
      end
    end
=end

      it 'should have related objects' do
        # many-to-many
        query_creator = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.creator)
        expect(query_creator.count).to eq 1

        query_creator.each_statement do |s|
          expect(s.object).to eq person.rdf_subject
        end

        # one-sided has-many
        query_subject = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.subject)
        expect(query_subject.count).to eq 1

        query_subject.each_statement do |s|
          expect(s.object).to eq concept.rdf_subject
        end

        # embedded-one
        # TODO
      end

      it 'should have related object relations' do
        # many-to-many
        query = person.resource.query(subject: person.rdf_subject, predicate: RDF::DC.relation)
        expect(query.count).to eq 1
        expect(query.to_hash).to eq person.resource.statements.to_hash

        query.each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
        
        # one-sided has-many
        expect(subject.resource.query(subject: concept.rdf_subject)).to be_empty
        expect(concept.resource.statements).to be_empty

        # embedded-one
        # TODO
      end
    end

    context '#update_resource with related and then without related' do
      before do
        subject.update_resource(related: true)
        subject.update_resource # implicit false
      end

      it 'should not have related objects' do
        expect(subject.resource.query(subject: person.rdf_subject)).to be_empty
        expect(subject.resource.query(subject: concept.rdf_subject)).to be_empty
      end

      it 'should have related object relations' do
        # many-to-many
        query = person.resource.query(subject: person.rdf_subject, predicate: RDF::DC.relation)
        expect(query.count).to eq 1
        expect(query.to_hash).to eq person.resource.statements.to_hash

        query.each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
        
        # one-sided has-many
        expect(subject.resource.query(subject: concept.rdf_subject)).to be_empty
        expect(concept.resource.statements).to be_empty

        # embedded-one
        # TODO
      end
    end

    context 'serializable' do

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

  context 'with data' do
    let(:subject) { Thing.new }

    include_context 'with data'
    it_behaves_like 'a Serializable'
    it_behaves_like 'a Resource'
  end

  context 'with relations' do
    let(:subject) { Thing.new }

    include_context 'with data'
    include_context 'with relations'
    it_behaves_like 'a Serializable'
    it_behaves_like 'a Resource'
  end

end