require 'spec_helper'

describe Ladder::Searchable::Resource do
  before do
    Elasticsearch::Client.new(host: 'localhost:9200', log: true).indices.delete index: '_all'

    class Thing
      include Ladder::Resource
      include Ladder::Searchable

      # FIXME: DRY out this block
      configure type: RDF::DC.BibliographicResource

      property :title,      predicate: RDF::DC.title           # localized String
      property :alt,        predicate: RDF::DC.alternative,    # non-localized String
                            localize: false
      property :references, predicate: RDF::DC.references      # URI
      property :referenced, predicate: RDF::DC.isReferencedBy  # Array
      property :is_valid,   predicate: RDF::DC.valid           # Boolean
      property :date,       predicate: RDF::DC.date            # Date
      property :issued,     predicate: RDF::DC.issued          # DateTime
      property :spatial,    predicate: RDF::DC.spatial         # Float
      # property :conformsTo, predicate: RDF::DC.conformsTo      # Hash
      property :identifier, predicate: RDF::DC.identifier      # Integer
      # property :license,    predicate: RDF::DC.license         # Range
      property :source,     predicate: RDF::DC.source          # Symbol
      property :created,    predicate: RDF::DC.created         # Time
      ###
    end
  end

  after do
    Ladder::Config.models.delete Thing
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
      Ladder::Config.models.delete Person
      Object.send(:remove_const, 'Person') if Object
    end
  end

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
