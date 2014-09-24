require 'spec_helper'

describe Ladder::Resource do
  before do
    class LadderExample
      include Ladder::Resource
    end
  end
  
  after do
    Object.send(:remove_const, "LadderExample") if Object
  end
  
  subject { Thing.new }
  let(:klass) { LadderExample }

  shared_context 'with data' do
    before do
      class MyResource
        include Ladder::Resource

        define :relation, predicate: RDF::DC.relation, class_name: 'LadderExample'
      end

      klass.define :title, predicate: RDF::DC.title
      klass.define :identifier, predicate: RDF::DC.identifier
      klass.define :description, predicate: RDF::DC.description

      subject.title = 'Moomin Valley in November'
      subject.identifier = 'moomvember'
      subject.description = 'The ninth and final book in the Moomin series by Finnish author Tove Jansson'
    end
    
    after do
      Object.send(:remove_const, 'MyResource')
    end
  end
end