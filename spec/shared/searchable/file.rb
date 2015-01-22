shared_context 'a Searchable File' do

  describe '#save' do
    before do
      subject.save
      Elasticsearch::Model.client.indices.flush
    end

    it 'should exist in the index' do
      results = subject.class.search('*')
      expect(results.count).to eq 1
      expect(results.first.id).to eq subject.id.to_s
    end

    it 'should contain full-text content' do
      results = subject.class.search 'Moomin*', fields: '*'
      expect(results.count).to eq 1
      expect(results.first.fields.file.first).to include 'Moomin'
    end
  end
  
  describe '#save with update' do
    before do
      subject.save
      subject.file = StringIO.new('It was a more serious smell than any he had met before, and slightly frightening.')
      subject.save
      Elasticsearch::Model.client.indices.flush
    end

    it 'should have updated full-text content' do
      results = subject.class.search 'frightening', fields: '*'
      expect(results.count).to eq 1
      expect(results.first.fields.file.first).to include 'frightening'
    end
  end

  describe '#destroy' do
    before do
      subject.save
      subject.destroy
      Elasticsearch::Model.client.indices.flush
    end

    it 'should not exist in the index' do
      results = subject.class.search('*')
      expect(results).to be_empty
    end
  end

end