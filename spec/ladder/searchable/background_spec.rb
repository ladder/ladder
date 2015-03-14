require 'spec_helper'

describe Ladder::Searchable::Background do
  before do
    Elasticsearch::Client.new(host: 'localhost:9200', log: true).indices.delete index: '_all'

    class BackgroundSearchableThing
      include Ladder::Resource
      include Ladder::Searchable::Background
    end

    class BackgroundSearchableDatastream
      include Ladder::File
      include Ladder::Searchable::Background
    end
  end

  after do
    Ladder::Config.models.delete BackgroundSearchableThing
    Object.send(:remove_const, 'BackgroundSearchableThing') if Object

    Ladder::Config.models.delete BackgroundSearchableDatastream
    Object.send(:remove_const, 'BackgroundSearchableDatastream') if Object
  end

  include_context 'configure_thing'

  shared_context 'with relations' do
    let(:person) { BackgroundSearchablePerson.new }

    before do
      class BackgroundSearchablePerson
        include Ladder::Resource
        include Ladder::Searchable::Background
        configure type: RDF::FOAF.Person

        property :foaf_name, predicate: RDF::FOAF.name
        property :things, predicate: RDF::DC.relation, class_name: 'BackgroundSearchableThing'
      end
    end

    after do
      Ladder::Config.models.delete BackgroundSearchablePerson
      Object.send(:remove_const, 'BackgroundSearchablePerson') if Object
    end
  end

  context 'with data' do
    let(:subject) { BackgroundSearchableThing.new }

    include_context 'with data'

    it_behaves_like 'a Searchable'
  end

  context 'with relations' do
    let(:subject) { BackgroundSearchableThing.new }

    include_context 'with data'
    include_context 'with relations'

    before do
      # many-to-many relation
      Thing.property :people, predicate: RDF::DC.creator, class_name: 'BackgroundSearchablePerson'

      # related object
      person.foaf_name = 'Tove Jansson'
      subject.people << person
    end

    it_behaves_like 'a Searchable'
    it_behaves_like 'a Searchable with related'
  end

  context 'with data from file' do
    TEST_FILE ||= './spec/shared/moomin.pdf'

    let(:subject) { BackgroundSearchableDatastream.new file: open(TEST_FILE) }
    let(:source) { open(TEST_FILE).read } # ASCII-8BIT (binary)

    it_behaves_like 'a Searchable File'
  end

  context 'with data from string after creation' do
    data = 'And so Moomintroll was helplessly thrown out into a strange and dangerous world and dropped
            up to his ears in the first snowdrift of his experience. It felt unpleasantly prickly to his
            velvet skin, but at the same time his nose caught a new smell. It was a more serious smell
            than any he had met before, and slightly frightening. But it made him wide awake and greatly
            interested.'

    let(:subject) { BackgroundSearchableDatastream.new }
    let(:source) { data } # UTF-8 (string)

    before do
      subject.file = StringIO.new(source)
    end

    it_behaves_like 'a Searchable File'
  end
end
