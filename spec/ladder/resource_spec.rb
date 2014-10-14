require 'spec_helper'
require 'pry'

describe Ladder::Resource do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI = 'http://example.org'

    class Thing
      include Ladder::Resource
    end

    class Person
      include Ladder::Resource
    end
  end
  
  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Thing") if Object
    Object.send(:remove_const, "Person") if Object
  end

  subject { Thing.new }
  let(:person) { Person.new }

  shared_context 'with data' do
    let(:concept) { Concept.new }
    let(:part)    { Part.new }
    
    before do
      class Concept
        include Ladder::Resource
      end

      class Part
        include Ladder::Resource
        embedded_in :thing
        property :thing, :predicate => RDF::DC.relation, :class_name => 'Thing'
      end

      # localized literal
      subject.class.property :title, :predicate => RDF::DC.title
      subject.title = 'Comet in Moominland'

      # many-to-many
      person.class.property :things, :predicate => RDF::DC.relation, :class_name => 'Thing'
      subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'
      subject.people << person

      # one-sided has-many
      subject.class.has_and_belongs_to_many :concepts, inverse_of: nil
      subject.class.property :concepts, :predicate => RDF::DC.subject, :class_name => 'Concept'
      subject.concepts << concept

      # embedded many
      subject.class.embeds_many :parts, cascade_callbacks: true
      subject.class.property :parts, :predicate => RDF::DC.hasPart, :class_name => 'Part'
      subject.parts << part
      subject.save
    end

    after do
      Object.send(:remove_const, 'Concept')
      Object.send(:remove_const, 'Part')
    end

    it 'should have relations' do
      expect(subject.title).to eq 'Comet in Moominland'
      expect(subject.people.to_a).to include person
      expect(subject.concepts.to_a).to include concept
      expect(subject.parts.to_a).to include part
    end
    
    it 'should have reverse relations' do
      expect(person.things.to_a).to include subject
      expect(concept.relations).to be_empty
      expect(part.thing).to eq subject
    end
  end

  describe 'LADDER_BASE_URI' do
    it 'should automatically have a base URI' do
      expect(subject.rdf_subject.parent).to eq RDF::URI('http://example.org/things/')
    end
  end

  describe '#property' do
    context 'with localized literal' do
      before do
        subject.class.property :title, :predicate => RDF::DC.title
        subject.title = 'Comet in Moominland'
      end
      
      it 'should return localized value' do
        expect(subject.title).to eq 'Comet in Moominland'
      end
      
      it 'should return all locales' do
        expect(subject.attributes['title']).to eq Hash({'en' => 'Comet in Moominland'})
      end
      
      it 'should have a valid predicate' do
        expect(subject.class.properties).to include 'title'
        expect(t = subject.class.properties['title']).to be_a ActiveTriples::NodeConfig
        expect(t.predicate).to eq RDF::DC.title
      end
    end

    context 'with many-to-many' do
      before do
        subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'
        person.class.property :things, :predicate => RDF::DC.relation, :class_name => 'Thing'
        subject.people << person
        subject.save
      end

      it 'should have a relation' do
        expect(subject.relations).to include 'people'
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(subject.people.to_a).to include person
      end

      it 'should have an inverse relation' do
        expect(person.relations).to include 'things'
        expect(person.relations['things'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(person.things.to_a).to include subject
      end

      it 'should have a valid predicate' do
        expect(subject.class.properties).to include 'people'
        expect(t = subject.class.properties['people']).to be_a ActiveTriples::NodeConfig
        expect(t.predicate).to eq RDF::DC.creator
      end

      it 'should have a valid inverse predicate' do
        expect(person.class.properties).to include 'things'
        expect(t = person.class.properties['things']).to be_a ActiveTriples::NodeConfig
        expect(t.predicate).to eq RDF::DC.relation
      end
    end

    context 'with one-sided has-many' do
      before do
        subject.class.has_and_belongs_to_many :people, inverse_of: nil
        subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'
        subject.people << person
      end

      it 'should have a relation' do
        expect(subject.relations).to include 'people'
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(subject.people.to_a).to include person
      end

      it 'should not have an inverse relation' do
        expect(subject.relations['people'].inverse_of).to be nil
        expect(person.relations).to be_empty
      end

      it 'should have a valid predicate' do
        expect(subject.class.properties).to include 'people'
        expect(t = subject.class.properties['people']).to be_a ActiveTriples::NodeConfig
        expect(t.predicate).to eq RDF::DC.creator
      end

      it 'should not have an inverse predicate' do
        expect(person.class.properties).to be_empty
      end
    end

    context 'with embeds-many' do
      before do
        subject.class.embeds_many :people
        subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'

        person.class.embedded_in :thing
        person.class.property :thing, :predicate => RDF::DC.relation, :class_name => 'Thing'

        subject.people << person
      end

      it 'should have a relation' do
        expect(subject.relations).to include 'people'
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Embedded::Many)
        expect(subject.people.to_a).to include person
      end

      it 'should have an inverse relation' do
        expect(person.relations).to include 'thing'
        expect(person.relations['thing'].relation).to eq (Mongoid::Relations::Embedded::In)
        expect(person.thing).to eq subject
      end

      it 'should have a valid predicate' do
        expect(subject.class.properties).to include 'people'
        expect(t = subject.class.properties['people']).to be_a ActiveTriples::NodeConfig
        expect(t.predicate).to eq RDF::DC.creator
      end

      it 'should have a valid inverse predicate' do
        expect(person.class.properties).to include 'thing'
        expect(t = person.class.properties['thing']).to be_a ActiveTriples::NodeConfig
        expect(t.predicate).to eq RDF::DC.relation
      end
    end  
  end

  describe '#update_resource' do

    context 'without related: true' do
      include_context 'with data'
      
      before do
        subject.update_resource
      end

      it 'should have a literal object' do
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.title).each_statement do |s|
          expect(s.object.to_s).to eq 'Comet in Moominland'
        end
      end

      it 'should have an embedded object' do
        subject.resource.query(:subject => part.rdf_subject, :predicate => RDF::DC.relation).each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end

      it 'should have an embedded object relation' do
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.hasPart).each_statement do |s|
          expect(s.object).to eq part.rdf_subject
        end
      end

      it 'should not have related objects' do
        expect(subject.resource.query(:subject => person.rdf_subject)).to be_empty
        expect(subject.resource.query(:subject => concept.rdf_subject)).to be_empty
      end

      it 'should not have related object relations' do
        expect(person.resource.statements).to be_empty
        expect(concept.resource.statements).to be_empty
      end
    end

    context 'with related: true' do
      include_context 'with data'
      
      before do
        subject.update_resource(:related => true)
      end

      it 'should have a literal object' do
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.title).each_statement do |s|
          expect(s.object.to_s).to eq 'Comet in Moominland'
        end
      end

      it 'should have an embedded object' do
        subject.resource.query(:subject => part.rdf_subject, :predicate => RDF::DC.relation).each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end

      it 'should have an embedded object relation' do
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.hasPart).each_statement do |s|
          expect(s.object).to eq part.rdf_subject
        end
      end

      it 'should have related objects' do
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.subject).each_statement do |s|
          expect(s.object).to eq concept.rdf_subject
        end
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.creator).each_statement do |s|
          expect(s.object).to eq person.rdf_subject
        end
      end

      it 'should have related object relations' do
        person.resource.query(:subject => person.rdf_subject, :predicate => RDF::DC.relation).each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end
    end
  end
  
  describe '#as_jsonld' do
    include_context 'with data'
    
    before do
      subject.update_resource
    end
    
    it 'should output a valid jsonld representation of itself' do
      g = RDF::Graph.new << JSON::LD::API.toRdf(JSON.parse subject.as_jsonld)
      expect(subject.resource.to_hash == g.to_hash).to be true
    end
  end

end