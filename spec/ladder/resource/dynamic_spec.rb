require 'spec_helper'

describe Ladder::Resource::Dynamic do
  before do
    class Thing
      include Ladder::Resource::Dynamic

      # FIXME: DRY out this block
      configure type: RDF::DC.BibliographicResource

      property :title,      predicate: RDF::DC.title,          # localized String
                            localize: true
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

  context 'with data' do
    let(:subject) { Thing.new }

    include_context 'with data'

    it_behaves_like 'a Resource'
    it_behaves_like 'a Dynamic Resource'
  end

  context 'from JSON-LD' do
    let(:subject) { Thing.new_from_graph(RDF::Graph.load './spec/shared/graph.jsonld') }

    it_behaves_like 'a Resource'
    it_behaves_like 'a Dynamic Resource'
  end
end
