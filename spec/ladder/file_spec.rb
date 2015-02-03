require 'spec_helper'

describe Ladder::File do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI ||= 'http://example.org'

    class Datastream
      include Ladder::File
    end
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Datastream") if Object
  end

  shared_context 'with relations' do
    let(:thing)    { Thing.new }

    before do
      class Thing
        include Ladder::Resource
      end

      # implicit from #property
      thing.class.property :files, predicate: RDF::DC.relation, class_name: subject.class.name, inverse_of: nil
      thing.files << subject
      thing.save

      # TODO: build some relations of various types
      # explicit using HABTM
      # explicit has-one
    end

    after do
      Object.send(:remove_const, 'Thing') if Object
    end

    context 'with one-sided has-many' do
      it 'should have a relation' do
        expect(thing.relations['files'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(thing.files.to_a).to include subject
      end

      it 'should not have an inverse relation' do
        expect(thing.relations['files'].inverse_of).to be nil
        expect(subject.relations).to be_empty
      end

      it 'should have a valid predicate' do
        expect(thing.class.properties['files'].predicate).to eq RDF::DC.relation
      end

      it 'should not have an inverse predicate' do
        expect(subject.class.properties).to be_empty
      end
    end

  end

  context 'with data from file' do
    TEST_FILE ||= './spec/shared/moomin.pdf'

    let(:subject) { Datastream.new file: open(TEST_FILE) }
    let(:source) { open(TEST_FILE).read } # ASCII-8BIT (binary)

    include_context 'with relations'
    it_behaves_like 'a File'
  end

  context 'with data from string after creation' do
    data = "And so Moomintroll was helplessly thrown out into a strange and dangerous world and dropped up to his ears in the first snowdrift of his experience. It felt unpleasantly prickly to his velvet skin, but at the same time his nose caught a new smell. It was a more serious smell than any he had met before, and slightly frightening. But it made him wide awake and greatly interested."

    let(:subject) { Datastream.new }
    let(:source) { data } # UTF-8 (string)

    before do
      subject.file = StringIO.new(source)
    end

    include_context 'with relations'
    it_behaves_like 'a File'
  end

end
