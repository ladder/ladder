require 'mimemagic'

shared_examples 'a File' do

  shared_context 'with relations' do
    let(:thing)    { Thing.new }

    before do
      class Thing
        include Ladder::Resource
      end

      # implicit from #property
      thing.class.property :files, :predicate => RDF::DC.relation, :class_name => subject.class.name, :inverse_of => nil
      thing.files << subject
      
      # TODO: build some relations of various types
      # explicit using HABTM
      # explicit has-one
    end

    after do
      Object.send(:remove_const, 'Thing')
    end
  end

  describe 'LADDER_BASE_URI' do
    it 'should automatically have a base URI' do
      expect(subject.rdf_subject.parent).to eq RDF::URI('http://example.org/datastreams/')
    end
  end

  describe '#initialize' do
    it 'should have an id' do
      expect(subject.id).to be_kind_of BSON::ObjectId
    end
  end

  describe '#data' do
    it 'should return a data stream' do
      expect(subject.data).to eq source.force_encoding(subject.data.encoding)
    end
  end

  describe '#save' do
    it 'should persist' do
      expect(subject.save).to be true
    end
  end

  describe '#find' do
    it 'should be retrievable' do
      subject.save
      found = subject.class.find(subject.id)

      expect(found).to eq subject
      expect(found.data).to eq subject.data
      expect(found.data).to eq source.force_encoding(found.data.encoding)
    end
  end

  describe '#attributes' do
    before do
      subject.save
      subject.reload
    end
    
    it 'should have a #length' do
      expect(subject.length).to eq source.force_encoding(subject.data.encoding).length
    end
    
    it 'should have a #md5' do
      expect(subject.md5).to eq Digest::MD5.hexdigest(source)
    end
    
    it 'should have a #content_type' do
      source_type = MimeMagic.by_magic(source).to_s
      expect(subject.content_type).to eq source_type.empty? ? "application/octet-stream" : source_type
    end
  end

  describe '#update_resource' do
    it 'should not have related objects' do
      expect(subject.resource).to eq subject.update_resource
    end

    it 'should not have related object relations' do
      expect(subject.resource.statements).to be_empty
    end    
  end

  context 'with one-sided has-many' do
    include_context 'with relations'

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