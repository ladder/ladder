require 'spec_helper'

describe Ladder::Searchable::Resource do
  before do
    Elasticsearch::Client.new(host: 'localhost:9200', log: true).indices.delete index: '_all'

    class Thing
      include Ladder::Resource
      include Ladder::Searchable
      configure type: RDF::DC.BibliographicResource
    end
  end

  after do
    Object.send(:remove_const, 'Thing') if Object
  end

  shared_context 'with relations' do
    let(:person)  { Person.new }

    before do
      class Person
        include Ladder::Resource
        include Ladder::Searchable
        configure type: RDF::FOAF.Person

        property :foaf_name, predicate: RDF::FOAF.name
        property :things, predicate: RDF::DC.relation, class_name: 'Thing'
      end
    end

    after do
      Object.send(:remove_const, 'Person') if Object
    end
  end

  include_context 'configure_thing'

  context 'with data' do
    let(:subject) { Thing.new }

    include_context 'with data'

    it_behaves_like 'a Searchable'
  end

  context 'with relations' do
    let(:subject) { Thing.new }

    include_context 'with data'
    include_context 'with relations'

    before do
      # many-to-many relation
      Thing.property :people, predicate: RDF::DC.creator, class_name: 'Person'

      # related object
      person.foaf_name = 'Tove Jansson'
      subject.people << person
    end

    it_behaves_like 'a Searchable'
    it_behaves_like 'a Searchable with related'
  end
end
