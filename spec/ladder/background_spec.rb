require 'spec_helper'

describe Ladder::Searchable::Background do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    Elasticsearch::Model.client = Elasticsearch::Client.new host: 'localhost:9200', log: true
    Elasticsearch::Model.client.indices.delete index: '_all'

    LADDER_BASE_URI = 'http://example.org'

    class Thing
      include Ladder::Resource
      include Ladder::Searchable::Background
    end
  end
  
  let(:subject) { Thing.new }
  
  it 'should do something' do
    # TODO
    subject.save
  end

end