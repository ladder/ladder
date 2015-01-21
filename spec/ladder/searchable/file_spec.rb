require 'spec_helper'

describe Ladder::Searchable::File do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    Elasticsearch::Model.client = Elasticsearch::Client.new host: 'localhost:9200', log: true
    Elasticsearch::Model.client.indices.delete index: '_all'

    LADDER_BASE_URI ||= 'http://example.org'

    class Datastream
      include Ladder::File
      include Ladder::Searchable
    end
  end

  after do
    Object.send(:remove_const, "Datastream") if Object
  end

  shared_context 'searchable' do
    before do
      subject.save
      Elasticsearch::Model.client.indices.flush
    end

    it 'should exist in the index' do
      results = subject.class.search('Moomin*')
      expect(results.count).to eq 1
      expect(results.first.id).to eq subject.id.to_s
    end

    it 'should contain full-text content' do
      results = subject.class.search 'Moomin*', fields: '*'
      expect(results.count).to eq 1
      expect(results.first.fields.file.first).to include 'Moomin'
    end
  end

  context 'with data from file' do
    TEST_FILE ||= './spec/shared/moomin.pdf'

    let(:subject) { Datastream.new file: open(TEST_FILE) }
    let(:source) { open(TEST_FILE).read } # ASCII-8BIT (binary)

    it_behaves_like 'a File'

    include_context 'searchable'
  end

  context 'with data from string after creation' do
    data = "And so Moomintroll was helplessly thrown out into a strange and dangerous world and dropped up to his ears in the first snowdrift of his experience. It felt unpleasantly prickly to his velvet skin, but at the same time his nose caught a new smell. It was a more serious smell than any he had met before, and slightly frightening. But it made him wide awake and greatly interested."
    
    let(:subject) { Datastream.new }
    let(:source) { data } # UTF-8 (string)

    before do
      subject.file = StringIO.new(source)
    end

    it_behaves_like 'a File'

    include_context 'searchable'
  end

end