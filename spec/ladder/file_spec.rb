require 'spec_helper'

describe Ladder::File do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI = 'http://example.org'

    class Datastream
      include Ladder::File
    end
  end

  it_behaves_like 'a File'

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Datastream") if Object
  end
end