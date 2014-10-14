require 'spec_helper'
require 'pry'

describe Ladder::Searchable do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    Elasticsearch::Model.client = Elasticsearch::Client.new host: 'localhost:9200', log: true
    Elasticsearch::Model.client.indices.delete index: '_all'

    LADDER_BASE_URI = 'http://example.org'

    class Thing
      include Ladder::Resource
      include Ladder::Searchable
    end

    class Person
      include Ladder::Resource
      include Ladder::Searchable
    end
  end
  
  after do
    Object.send(:remove_const, "Thing") if Object
    Object.send(:remove_const, "Person") if Object
  end

  subject { Thing.new }
  let(:person) { Person.new }

  describe '#index' do
    before do
      subject.class.configure type: RDF::DC.BibliographicResource
      subject.class.property :title, :predicate => RDF::DC.title
      subject.title = 'Comet in Moominland'
    end

    context 'with default' do
      before do
        subject.class.index
        subject.save
        Elasticsearch::Model.client.indices.flush
      end

      it 'should exist in the index' do
        results = subject.class.search('title:moomin*')
        expect(results.count).to eq 1
      end

      it 'should contain a valid serialization' do
        results = subject.class.search('title:moomin*')
        expect(results.first._source.to_hash).to eq JSON.parse(subject.as_indexed_json.to_json)
      end
    end

    context 'with as qname' do
      before do
        subject.class.index as: :qname
        subject.save
        Elasticsearch::Model.client.indices.flush
      end

      it 'should exist in the index' do
        results = subject.class.search('dc.title.en:moomin*')
        expect(results.count).to eq 1
      end

      it 'should contain a valid serialization' do
        results = subject.class.search('dc.title.en:moomin*')
        expect(results.first._source.to_hash).to eq JSON.parse(subject.as_indexed_json.to_json)
      end
    end

    context 'with as jsonld' do
      before do
        subject.class.index as: :jsonld
        subject.save
        Elasticsearch::Model.client.indices.flush
      end
      
      it 'should exist in the index' do
        results = subject.class.search('dc\:title.@value:moomin*')
        expect(results.count).to eq 1
      end

      it 'should contain a valid serialization' do
        results = subject.class.search('dc\:title.@value:moomin*')
        expect(results.first._source.to_hash).to eq JSON.parse(subject.as_indexed_json)
      end
    end
    
    context 'with as_jsonld including related' do
      before do
        # related object
        person.class.configure type: RDF::FOAF.Person
        person.class.property :name, :predicate => RDF::FOAF.name
        person.class.property :things, :predicate => RDF::DC.relation, :class_name => 'Thing'
        person.class.index as: :jsonld
        person.name = 'Tove Jansson'

        # many-to-many relation
        subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'
        subject.people << person

        subject.class.index as: :jsonld
        subject.save
        Elasticsearch::Model.client.indices.flush
      end
      
      it 'should exist in the index' do
        results = subject.class.search('dc\:title.@value:moomin*')
        expect(results.count).to eq 1
      end

      it 'should contain a valid serialization' do
        results = subject.class.search('dc\:title.@value:moomin*')
        expect(results.first._source.to_hash).to eq JSON.parse(subject.as_indexed_json)
      end
      
      it 'should include the related object in the index' do
        results = person.class.search('foaf\:name.@value:tove')
        expect(results.count).to eq 1
      end

      it 'should contain a valid serialization of the related object' do
        results = person.class.search('foaf\:name.@value:tove')
        expect(results.first._source.to_hash).to eq JSON.parse(person.as_indexed_json)
      end
    end
  end

end