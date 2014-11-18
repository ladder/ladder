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

  context 'with data from file' do
    let(:subject) { Datastream.new File.open('./spec/shared/moomin.jpg') }
    let(:source) { File.read('./spec/shared/moomin.jpg') }

    it_behaves_like 'a File'
  end

  context 'with data from string' do
    data = "And so Moomintroll was helplessly thrown out into a strange and dangerous world and dropped up to his ears in the first snowdrift of his experience. It felt unpleasantly prickly to his velvet skin, but at the same time his nose caught a new smell. It was a more serious smell than any he had met before, and slightly frightening. But it made him wide awake and greatly interested."
    let(:subject) { Datastream.new(data: data) }
    let(:source) { data }

    it_behaves_like 'a File'
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Datastream") if Object
  end
end