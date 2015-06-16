require 'spec_helper'

describe Ladder::Resource do
  before do
    class Thing
      include Ladder::Resource
    end
  end

  after do
    Ladder::Config.models.delete Thing
    Object.send(:remove_const, 'Thing') if Object
  end

  context 'with data' do
    let(:klass) { Thing }

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
      Ladder::Config.models.delete Subthing
      Object.send(:remove_const, 'Subthing') if Object
    end

    let(:klass) { Subthing }

    include_context 'with data'
    it_behaves_like 'a Resource'
  end

  context 'with relations' do
    let(:klass) { Thing }

    include_context 'with relations'

    before do
      subject.people << person    # many-to-many
      subject.concepts << concept # one-sided has-many
      subject.part = part         # embedded one
      subject.save
    end

    it_behaves_like 'a Resource with relations'
  end

=begin
  context 'from JSON-LD' do
    let(:klass) { Thing }

    include_context 'with relations'

    let(:subject) { Thing.new_from_graph(RDF::Graph.load './spec/shared/graph.jsonld') }

    let(:person)  { subject.people.first }
    let(:concept) { subject.concepts.first }
    let(:part)    { subject.part }

    before do
      subject.save
    end

    it_behaves_like 'a Resource with relations'
  end
=end
end
