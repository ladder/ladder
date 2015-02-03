require 'mimemagic'

shared_examples 'a File' do

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
    before do
      subject.save
    end

    it 'should be retrievable' do
      found = subject.class.find(subject.id)
      expect(found).to eq subject
      expect(found.data).to eq subject.data
      expect(found.data).to eq source.force_encoding(found.data.encoding)
    end
  end

  describe '#grid' do
    # TODO
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
      expect(subject.content_type).to eq source_type.empty? ? 'application/octet-stream' : source_type
    end
  end

  describe '#update_resource' do
    it 'should not have related objects' do
      expect(subject.resource).to eq subject.update_resource
    end

    it 'should not have any statements' do
      expect(subject.update_resource.statements).to be_empty
    end
  end

end
