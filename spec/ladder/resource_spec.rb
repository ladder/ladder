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
    end
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, 'Thing') if Object
  end

  shared_context 'with data' do
    before do
      subject.class.configure type: RDF::DC.BibliographicResource

      # non-localized literal
      subject.class.field :alt
      subject.class.property :alt, predicate: RDF::DC.alternative
      subject.alt = 'Mumintrollet pa kometjakt'

      # localized literal
      subject.class.property :title, predicate: RDF::DC.title
      subject.title = 'Comet in Moominland'
    end
  end

  shared_context 'with relations' do
    let(:person)  { Person.new }
    let(:concept) { Concept.new }
    let(:part)    { Part.new }

    before do
      class Person
        include Ladder::Resource
      end

      class Concept
        include Ladder::Resource
      end

      class Part
        include Ladder::Resource
      end

      person.class.configure type: RDF::DC.AgentClass
      concept.class.configure type: RDF::SKOS.Concept
      part.class.configure type: RDF::DC.PhysicalResource

      # many-to-many
      person.class.property :things, predicate: RDF::DC.relation, class_name: 'Thing'
      subject.class.property :people, predicate: RDF::DC.creator, class_name: 'Person'
      subject.people << person

      # one-sided has-many
      subject.class.has_and_belongs_to_many :concepts, inverse_of: nil, autosave: true
      subject.class.property :concepts, predicate: RDF::DC.subject, class_name: 'Concept'
      subject.concepts << concept

      # embedded one
      part.class.embedded_in :thing
      part.class.property :thing, predicate: RDF::DC.relation, class_name: 'Thing'
      subject.class.embeds_one :part, cascade_callbacks: true
      subject.class.property :part, predicate: RDF::DC.hasPart, class_name: 'Part'
      subject.part = part
      subject.save
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

  context 'with relations' do
    let(:subject) { Thing.new }

    include_context 'with data'
    include_context 'with relations'

    it_behaves_like 'a Resource'
    it_behaves_like 'a Resource with relations'
  end

  context 'from JSON-LD' do
    TEST_FILE ||= './spec/shared/graph.jsonld'

    let(:subject) { Thing.new }

    include_context 'with data'
    include_context 'with relations'

    it 'should do something' do
      # TODO: clean this up
      def remove_ids(x)
        if x.is_a?(Hash)
          x.reduce({}) do |m, (k, v)|
            m[k] = remove_ids(v) unless k == '@id'
            m
          end
        else
          x
        end
      end

      graph = RDF::Graph.load TEST_FILE
      new_subject = subject.class.new_from_graph(graph)

      # Frame loaded RDF graph
      json_hash = JSON.parse graph.dump(:jsonld, standard_prefixes: true)
      context = json_hash['@context']
      frame = { '@context' => context, '@type' => 'dc:BibliographicResource' }
      framed_jsonld = JSON::LD::API.compact(JSON::LD::API.frame(json_hash, frame), context)

      expect(remove_ids(new_subject.as_framed_jsonld)).to eq remove_ids(framed_jsonld)
    end

  end

end
