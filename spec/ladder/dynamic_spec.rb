require 'spec_helper'

describe Ladder::Resource::Dynamic do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI = 'http://example.org'

    class Thing
      include Ladder::Resource::Dynamic
    end

    class Person
      include Ladder::Resource::Dynamic
    end
  end

  it_behaves_like 'a Resource'
  
  # TODO: Add specs

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Thing") if Object
    Object.send(:remove_const, "Person") if Object
  end
end