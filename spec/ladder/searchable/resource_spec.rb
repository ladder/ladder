require 'spec_helper'

describe Ladder::Searchable::Resource do
  before do
    Elasticsearch::Client.new(host: 'localhost:9200', log: true).indices.delete index: '_all'

    class SearchableThing
      include Ladder::Resource
      include Ladder::Searchable
    end
  end

  after do
    Ladder::Config.models.delete SearchableThing
    Object.send(:remove_const, 'SearchableThing') if Object
  end

  include_context 'configure_thing'

  shared_context 'with relations' do
    let(:person)  { SearchablePerson.new }

    before do
      class SearchablePerson
        include Ladder::Resource
        include Ladder::Searchable
        configure type: RDF::FOAF.Person

        property :foaf_name, predicate: RDF::FOAF.name
        property :things, predicate: RDF::DC.relation, class_name: 'SearchableThing'
      end
    end

    after do
      Ladder::Config.models.delete SearchablePerson
      Object.send(:remove_const, 'SearchablePerson') if Object
    end
  end

  context 'with data' do
    let(:subject) { SearchableThing.new }

    include_context 'with data'

    it_behaves_like 'a Searchable'
  end

  context 'with relations' do
    let(:subject) { SearchableThing.new }

    include_context 'with data'
    include_context 'with relations'

    before do
      # many-to-many relation
      Thing.property :people, predicate: RDF::DC.creator, class_name: 'SearchablePerson'

      # related object
      person.foaf_name = 'Tove Jansson'
      subject.people << person
    end

    it_behaves_like 'a Searchable'
    it_behaves_like 'a Searchable with related'
  end
end
