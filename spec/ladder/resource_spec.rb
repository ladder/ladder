require 'spec_helper'

describe Ladder::Resource do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI ||= 'http://example.org'

    class Thing
      include Ladder::Resource
      configure type: RDF::DC.BibliographicResource

      property :alt,        predicate: RDF::DC.alternative, # non-localized String
                            localize: false
      property :title,      predicate: RDF::DC.title        # localized String
#      property :references, predicate: RDF::DC.references   # Array
      property :is_valid,   predicate: RDF::DC.valid        # Boolean
      property :date,       predicate: RDF::DC.date         # Date
      property :issued,     predicate: RDF::DC.issued       # DateTime
      property :spatial,    predicate: RDF::DC.spatial      # Float
#      property :conformsTo, predicate: RDF::DC.conformsTo   # Hash
      property :identifier, predicate: RDF::DC.identifier   # Integer
#      property :license,    predicate: RDF::DC.license      # Range
      property :source,     predicate: RDF::DC.source       # Symbol
      property :created,    predicate: RDF::DC.created      # Time
    end
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, 'Thing') if Object
  end

  shared_context 'with relations' do
    let(:person)  { Person.new }
    let(:concept) { Concept.new }
    let(:part)    { Part.new }

    before do
      class Person
        include Ladder::Resource
        configure type: RDF::DC.AgentClass

        property :things, predicate: RDF::DC.relation, class_name: 'Thing'
      end

      class Concept
        include Ladder::Resource
        configure type: RDF::SKOS.Concept
      end

      class Part
        include Ladder::Resource
        configure type: RDF::DC.PhysicalResource

        embedded_in :thing
        property :thing, predicate: RDF::DC.relation, class_name: 'Thing'
      end

      # many-to-many
      Thing.property :people, predicate: RDF::DC.creator, class_name: 'Person'

      # one-sided has-many
      Thing.has_and_belongs_to_many :concepts, inverse_of: nil, autosave: true
      Thing.property :concepts, predicate: RDF::DC.subject, class_name: 'Concept'

      # embedded one
      Thing.embeds_one :part, cascade_callbacks: true
      Thing.property :part, predicate: RDF::DC.hasPart, class_name: 'Part'
    end

    after do
      Object.send(:remove_const, 'Person') if Object
      Object.send(:remove_const, 'Concept') if Object
      Object.send(:remove_const, 'Part') if Object
    end
  end

  context 'with data' do
    let(:subject) { Thing.new }

    include_context 'with data'

    it_behaves_like 'a Resource'
  end

  context 'with subclass' do
    before do
      class Subthing < Thing
        # types are not inherited, so we must set it explicitly
        configure type: RDF::DC.BibliographicResource
      end
    end

    after do
      Object.send(:remove_const, 'Subthing') if Object
    end

    let(:subject) { Subthing.new }

    include_context 'with data'

    it_behaves_like 'a Resource'
  end

  context 'with relations' do
    let(:subject) { Thing.new }

    include_context 'with data'
    include_context 'with relations'

    before do
      subject.people << person    # many-to-many
      subject.concepts << concept # one-sided has-many
      subject.part = part         # embedded one
      subject.save
    end

    it_behaves_like 'a Resource'
    it_behaves_like 'a Resource with relations'
  end

  context 'from JSON-LD' do
    let(:subject) { Thing.new_from_graph(RDF::Graph.load './spec/shared/graph.jsonld') }

    include_context 'with relations'

    let(:person)  { subject.people.first }
    let(:concept) { subject.concepts.first }
    let(:part)    { subject.part }

    before do
      subject.save
    end

    it_behaves_like 'a Resource'
    it_behaves_like 'a Resource with relations'
  end
end
