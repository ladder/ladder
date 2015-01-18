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
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Thing") if Object
  end

  shared_context 'with relations' do
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
  end

  context 'with data' do
    let(:subject) { Thing.new }

    it_behaves_like 'a Searchable'
    it_behaves_like 'a Resource'
  end

  context 'with relations' do
    let(:subject) { Thing.new }

    include_context 'with relations'
    it_behaves_like 'a Searchable'
    it_behaves_like 'a Resource'
  end

end