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
      data = subject.class.find(subject.id).data

      expect(data).to eq subject.data
      expect(data).to eq source.force_encoding(data.encoding)
    end
  end

  describe '#==' do
    it 'should be comparable' do
      subject.save

      expect(subject.class.find(subject.id)).to eq subject
    end
  end

end