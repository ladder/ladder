require 'spec_helper'

describe Ladder::Searchable::Background do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    Elasticsearch::Model.client = Elasticsearch::Client.new host: 'localhost:9200', log: true
    Elasticsearch::Model.client.indices.delete index: '_all'

    LADDER_BASE_URI ||= 'http://example.org'

    class Thing
      include Ladder::Resource
      include Ladder::Searchable::Background
    end

    class Datastream
      include Ladder::File
      include Ladder::Searchable::Background
    end
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Thing") if Object
    Object.send(:remove_const, "Datastream") if Object
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
  end

  context 'with data' do
    let(:subject) { Thing.new }

    include_context 'with data'

    it_behaves_like 'a Searchable'
  end

  context 'with relations' do
    let(:subject) { Thing.new }
    let(:person)  { Person.new }

    before do
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
    it_behaves_like 'a Searchable with related'
  end

  context 'with data from file' do
    TEST_FILE ||= './spec/shared/moomin.pdf'

    let(:subject) { Datastream.new file: open(TEST_FILE) }
    let(:source) { open(TEST_FILE).read } # ASCII-8BIT (binary)

    it_behaves_like 'a Searchable File'
  end

  context 'with data from string after creation' do
    data = "And so Moomintroll was helplessly thrown out into a strange and dangerous world and dropped up to his ears in the first snowdrift of his experience. It felt unpleasantly prickly to his velvet skin, but at the same time his nose caught a new smell. It was a more serious smell than any he had met before, and slightly frightening. But it made him wide awake and greatly interested."

    let(:subject) { Datastream.new }
    let(:source) { data } # UTF-8 (string)

    before do
      subject.file = StringIO.new(source)
    end

    it_behaves_like 'a Searchable File'
  end

end
