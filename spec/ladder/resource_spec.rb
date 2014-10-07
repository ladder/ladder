require 'spec_helper'
require 'mongoid'
require 'pry'
Mongoid.load!('mongoid.yml', :development)

Mongoid.logger.level = Logger::DEBUG
Moped.logger.level = Logger::DEBUG

describe Ladder::Resource do
  before do
    LADDER_BASE_URI = 'http://example.org'

    class Thing
      include Ladder::Resource
    end
    
    class Person
      include Ladder::Resource
    end
  end
  
  after do
    Object.send(:remove_const, "Thing") if Object
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
  end

  subject { Thing.new }
  let(:person) { Person.new }

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
      
      it 'should update the value in the resource' do
        subject.update_resource
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.title).each_statement do |s|
          expect(s.object.to_s).to eq 'Comet in Moominland'
        end
      end
    end

    context 'with many-to-many' do
      before do
        subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'
        person.class.property :things, :predicate => RDF::DC.relation, :class_name => 'Thing'
        subject.people << person
        subject.save
      end

      it 'should set a relation' do
        expect(subject.relations).to include 'people'
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(subject.people).to include person
      end

      it 'should set an inverse relation' do
        expect(person.relations).to include 'things'
        expect(person.relations['things'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(person.things).to include subject
      end

      it 'should set a valid predicate' do
        subject.update_resource
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.creator).each_statement do |s|
          expect(s.object).to eq person.rdf_subject
        end
      end

      it 'should set a valid inverse predicate' do
        person.update_resource
        person.resource.query(:subject => person.rdf_subject, :predicate => RDF::DC.relation).each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end
    end

    context 'with one-sided has-many' do
      before do
        subject.class.has_and_belongs_to_many :people, inverse_of: nil
        subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'

        subject.people << person
        subject.save
      end

      it 'should set a relation' do
        expect(subject.relations).to include 'people'
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(subject.people).to include person
      end

      it 'should not set an inverse relation' do
        expect(subject.relations['people'].inverse_of).to be nil

        expect(person.relations).to include 'things'
        expect(person.relations['things'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(person.things).to be_empty
      end

      it 'should set a valid predicate' do
        subject.update_resource
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.creator).each_statement do |s|
          expect(s.object).to eq person.rdf_subject
        end
      end

      it 'should not set an inverse predicate' do
        person.update_resource
        expect(person.resource.query(:subject => person.rdf_subject)).to be_empty
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

      it 'should set a relation' do
        expect(subject.relations).to include 'people'
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Embedded::Many)
        expect(subject.people).to include person
      end

      it 'should set an inverse relation' do
        expect(person.relations).to include 'thing'
        expect(person.relations['thing'].relation).to eq (Mongoid::Relations::Embedded::In)
        expect(person.thing).to eq subject
      end

      it 'should set a valid predicate' do
        subject.update_resource
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.creator).each_statement do |s|
          expect(s.object).to eq person.rdf_subject
        end
      end

      it 'should set a valid inverse predicate' do
        person.update_resource
        person.resource.query(:subject => person.rdf_subject, :predicate => RDF::DC.relation).each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end
    end
    
  end

end