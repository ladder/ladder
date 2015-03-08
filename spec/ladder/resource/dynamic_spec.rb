require 'spec_helper'

describe Ladder::Resource::Dynamic do
  before do
    class Thing
      include Ladder::Resource::Dynamic
    end
  end

  after do
    Object.send(:remove_const, 'Thing') if Object
  end

  include_context 'configure_thing'

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
