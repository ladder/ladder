require 'spec_helper'

describe Ladder::Resource do
  before do
    class Thing
      include Ladder::Resource
    end
  end

  after do
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

  include_context 'configure_thing'

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
