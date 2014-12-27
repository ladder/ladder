require 'mimemagic'

shared_examples 'a File' do

  shared_context 'with relations' do
    let(:concept) { Concept.new }
    let(:part)    { Part.new }

    before do
      class Concept
        include Ladder::Resource
      end

      class Part
        include Ladder::Resource
      end

      # TODO: build some relations of various types
      # implicit from #property
      # explicit using HABTM
      # explicit has-one
    end

    after do
      Object.send(:remove_const, 'Concept')
      Object.send(:remove_const, 'Part')
    end
    
    # TODO
=begin
    it 'should have relations' do
      expect(subject.title).to eq 'Comet in Moominland'
      expect(subject.people.to_a).to include person
      expect(subject.concepts.to_a).to include concept
      expect(subject.part).to eq part
    end
    
    it 'should not have reverse relations' do
      expect(person.things.to_a).to include subject
      expect(concept.relations).to be_empty
      expect(part.thing).to eq subject
    end
=end
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
      expect(subject.data).to eq source
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

  context 'with one-sided has-many' do
    include_context 'with relations'
    
    # TODO
=begin
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
=end
  end
  
  # TODO: add blocks for other relation types

end