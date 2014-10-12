require 'spec_helper'
require 'pry'

describe Ladder::Searchable do
  before do
    Elasticsearch::Model.client = Elasticsearch::Client.new host: 'localhost:9200', log: true
    Elasticsearch::Model.client.indices.delete index: '_all'

    LADDER_BASE_URI = 'http://example.org'

    class Thing
      include Ladder::Resource
      include Ladder::Searchable
    end

    class Person
      include Ladder::Resource
      include Ladder::Searchable
    end
  end
  
  after do
    Object.send(:remove_const, "Thing") if Object
    Object.send(:remove_const, "Person") if Object
  end

  subject { Thing.new }
  let(:person) { Person.new }

  describe '#index' do

    context 'with default' do
      before do
        subject.class.index
        subject.save
      end

      # TODO
    end

    context 'with as qname' do
      before do
        subject.class.index as: :qname
        subject.save
      end
      
      # TODO
    end

    context 'with as jsonld' do
      before do
        subject.class.index as: :jsonld
        subject.save
      end
      
      # TODO
    end
    
    context 'with as_jsonld related: true' do
      before do
        subject.class.index as: :jsonld, related: true
        subject.save
      end

      # TODO
    end
  end

end