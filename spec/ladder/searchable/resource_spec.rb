require 'spec_helper'

describe Ladder::Searchable::Resource do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    Elasticsearch::Model.client = Elasticsearch::Client.new host: 'localhost:9200', log: true
    Elasticsearch::Model.client.indices.delete index: '_all'

    LADDER_BASE_URI ||= 'http://example.org'

    class Thing
      include Ladder::Resource
      include Ladder::Searchable
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

    context 'searchable' do
      describe '#index_for_search' do

        context 'with default' do
          before do
            subject.save
            Elasticsearch::Model.client.indices.flush
          end

          it 'should exist in the index' do
            results = subject.class.search('title:moomin*')
            expect(results.count).to eq 1
            expect(results.first._source.to_hash).to eq JSON.parse(subject.as_indexed_json.to_json)
          end
        end

        context 'with as qname' do
          before do
            subject.class.index_for_search { as_qname }
            subject.save
            Elasticsearch::Model.client.indices.flush
          end

          it 'should exist in the index' do
            results = subject.class.search('dc.title.en:moomin*')
            expect(results.count).to eq 1
            expect(results.first._source.to_hash).to eq JSON.parse(subject.as_qname.to_json)
          end
        end

        context 'with as jsonld' do
          before do
            subject.class.index_for_search { as_jsonld }
            subject.save
            Elasticsearch::Model.client.indices.flush
          end
    
          it 'should exist in the index' do
            results = subject.class.search('dc\:title.@value:moomin*')
            expect(results.count).to eq 1
            expect(results.first._source.to_hash).to eq subject.as_jsonld
          end
        end  
      end
    end
  end

  shared_context 'with relations' do
    before do
      # related object
      person.class.configure type: RDF::FOAF.Person
      person.class.property :foaf_name, predicate: RDF::FOAF.name
      person.foaf_name = 'Tove Jansson'

      # many-to-many relation
      person.class.property :things, predicate: RDF::DC.relation, class_name: 'Thing'
      subject.class.property :people, predicate: RDF::DC.creator, class_name: 'Person'
      subject.people << person
    end
    
    context 'searchable' do
      describe '#index_for_search related' do
          context 'with default' do
            before do
              subject.save
              Elasticsearch::Model.client.indices.flush
            end

            it 'should contain an ID for the related object' do
              results = subject.class.search('person_ids.$oid:' + person.id)
              expect(results.count).to eq 1
            end

            it 'should include the related object in the index' do
              results = person.class.search('foaf_name:tove')
              expect(results.count).to eq 1
              expect(results.first._source.to_hash).to eq JSON.parse(person.as_indexed_json.to_json)
            end

            it 'should contain an ID for the subject' do
              results = person.class.search('thing_ids.$oid:' + subject.id)
              expect(results.count).to eq 1
            end
          end

          context 'with as qname' do
            before do
              person.class.index_for_search { as_qname }
              subject.class.index_for_search { as_qname }
              subject.save
              Elasticsearch::Model.client.indices.flush
            end

            it 'should contain an ID for the related object' do
              results = subject.class.search('dc.creator:' + person.id)
              expect(results.count).to eq 1
            end

            it 'should include the related object in the index' do
              results = person.class.search('foaf.name.en:tove')
              expect(results.count).to eq 1
              expect(results.first._source.to_hash).to eq JSON.parse(person.as_qname.to_json)
            end

            it 'should contain an ID for the subject' do
              results = person.class.search('dc.relation:' + subject.id)
              expect(results.count).to eq 1
            end
          end

          context 'with as_qname related' do
            before do
              person.class.index_for_search { as_qname related: true }
              subject.class.index_for_search { as_qname related: true }
              subject.save
              Elasticsearch::Model.client.indices.flush
            end

            it 'should contain a embedded related object' do
              results = subject.class.search('dc.creator.foaf.name.en:tove')
              expect(results.count).to eq 1
              expect(results.first._source['dc']['creator'].first).to eq Hashie::Mash.new person.as_qname
            end

            it 'should contain an embedded subject in the related object' do
              results = person.class.search('dc.relation.dc.title.en:moomin*')
              expect(results.count).to eq 1
              expect(results.first._source['dc']['relation'].first).to eq Hashie::Mash.new subject.as_qname
            end
          end

          context 'with as_jsonld' do
            before do
              person.class.index_for_search { as_jsonld }
              subject.class.index_for_search { as_jsonld }
              subject.save
              Elasticsearch::Model.client.indices.flush
            end
      
            it 'should contain an ID for the related object' do
              results = subject.class.search('dc\:creator.@id:' + person.id)
              expect(results.count).to eq 1
            end

            it 'should include the related object in the index' do
              results = person.class.search('foaf\:name.@value:tove')
              expect(results.count).to eq 1
              expect(results.first._source.to_hash).to eq person.as_jsonld
            end

            it 'should contain an ID for the subject' do
              results = person.class.search('dc\:relation.@id:' + subject.id)
              expect(results.count).to eq 1
            end
          end

          context 'with as_jsonld related' do
            before do
              person.class.index_for_search { as_jsonld related: true }
              subject.class.index_for_search { as_jsonld related: true }
              subject.save
              Elasticsearch::Model.client.indices.flush
            end

            it 'should contain a embedded related object' do
              results = subject.class.search('@graph.foaf\:name.@value:tove')
              expect(results.count).to eq 1
            end

            it 'should contain an embedded subject in the related object' do
              results = person.class.search('dc\:relation.dc\:title.@value:moomin*')
              expect(results.count).to eq 1
            end
          end

          context 'with as_framed_jsonld' do
            before do
              person.class.index_for_search { as_framed_jsonld }
              subject.class.index_for_search { as_framed_jsonld }
              subject.save
              Elasticsearch::Model.client.indices.flush
            end

            it 'should contain a embedded related object' do
              results = subject.class.search('dc\:creator.foaf\:name.@value:tove')
              expect(results.count).to eq 1
            end

            it 'should contain an embedded subject in the related object' do
              results = person.class.search('dc\:relation.dc\:title.@value:moomin*')
              expect(results.count).to eq 1
            end
          end
      end
    end
  end
=begin
  context 'with data' do
    let(:subject) { Thing.new }

    include_context 'with data'
#    include_context 'with relations'
    it_behaves_like 'a Searchable'
    it_behaves_like 'a Resource'
  end

  context 'with data background' do
    let(:subject) { Thing.new }

    before do
      class Thing
        include Ladder::Resource
        include Ladder::Searchable::Background
      end
    end

    include_context 'with data'
#    include_context 'with relations'
    it_behaves_like 'a Searchable'
    it_behaves_like 'a Resource'
  end
=end
  context 'with relations' do
    let(:subject) { Thing.new }
    let(:person)  { Person.new }
    
    before do
      class Person
        include Ladder::Resource
        include Ladder::Searchable
      end
    end

    after do
      Object.send(:remove_const, "Person") if Object
    end

    include_context 'with data'
    include_context 'with relations'
    it_behaves_like 'a Searchable'
    it_behaves_like 'a Resource'
  end

  context 'with relations background' do
    let(:subject) { Thing.new }
    let(:person)  { Person.new }
    
    before do
      class Thing
        include Ladder::Resource
        include Ladder::Searchable::Background
      end

      class Person
        include Ladder::Resource
        include Ladder::Searchable::Background
      end
    end

    after do
      Object.send(:remove_const, "Person") if Object
    end

    include_context 'with data'
    include_context 'with relations'
    it_behaves_like 'a Searchable'
    it_behaves_like 'a Resource'
  end

end