require 'spec_helper'

describe Ladder::Resource do
  before do
    require 'mongoid'
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Logger::DEBUG
    Moped.logger.level = Logger::DEBUG

    LADDER_BASE_URI = 'http://example.org'

    class LadderExample
      include Ladder::Resource
      configure :type => RDF::OWL.Thing#, :base_uri => 'http://example.org/examples#'
    end
  end
  
  after do
    Object.send(:remove_const, "LadderExample") if Object
  end
  
  subject { MyResource.new }
  let(:klass) { MyResource }

  shared_context 'with data' do
    before do
      class MyResource
        include Ladder::Resource
        configure :type => RDF::OWL.Thing#, :base_uri => 'http://example.org/resources#'

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