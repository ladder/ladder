require 'spec_helper'

describe Ladder::Resource::Dynamic do
  before do
    class Thing
      include Ladder::Resource::Dynamic
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
    it_behaves_like 'a Dynamic Resource'
  end

  context 'from JSON-LD' do
    let(:klass) { Thing }

    include_context 'with data'
#    include_context 'with relations'

    let(:subject) { Thing.new_from_graph(RDF::Graph.load './spec/shared/graph.jsonld') }

    it_behaves_like 'a Resource'
    it_behaves_like 'a Dynamic Resource'
  end
end
