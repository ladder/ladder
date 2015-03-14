require 'spec_helper'

describe Ladder::Resource::Dynamic do
  before do
    class DynamicThing
      include Ladder::Resource::Dynamic
    end
  end

  after do
    Ladder::Config.models.delete DynamicThing
    Object.send(:remove_const, 'DynamicThing') if Object
  end

  include_context 'configure_thing'

  context 'with data' do
    let(:subject) { DynamicThing.new }

    include_context 'with data'

    it_behaves_like 'a Resource'
    it_behaves_like 'a Dynamic Resource'
  end

  context 'from JSON-LD' do
    let(:subject) { DynamicThing.new_from_graph(RDF::Graph.load './spec/shared/graph.jsonld') }

    it_behaves_like 'a Resource'
    it_behaves_like 'a Dynamic Resource'
  end
end
