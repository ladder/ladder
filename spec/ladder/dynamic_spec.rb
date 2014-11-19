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

  shared_context 'with data' do
    let(:subject) { Thing.new }

    before do
      # non-localized literal
      subject.class.field :alt
      subject.class.property :alt, :predicate => RDF::DC.alternative
      subject.alt = 'Mumintrollet pa kometjakt'

      # localized literal
      subject.class.property :title, :predicate => RDF::DC.title
      subject.title = 'Comet in Moominland'
    end
  end

  describe '#property' do
    include_context 'with data'

    context 'with undefined property' do
      before do
        subject.property :description, :predicate => RDF::DC.description
        subject.description = "Second in Tove Jansson's series of Moomin books"
      end

      it 'should create a context' do
        expect(subject._context).to eq({:description => RDF::DC.description.to_uri.to_s})
      end
      
      it 'should build an accessor' do
        expect(subject.description).to eq "Second in Tove Jansson's series of Moomin books"
      end
    end

    context 'with conflicting property' do
      before do
        subject.property :title, :predicate => RDF::DC11.title
        subject.dc11_title = "Kometjakten"
      end

      it 'should create a context' do
        expect(subject._context).to eq({:dc11_title => RDF::DC11.title.to_uri.to_s})
      end
      
      it 'should build an accessor' do
        expect(subject.dc11_title).to eq "Kometjakten"
      end
    end
  end

  describe '#<<' do
    include_context 'with data'

    context 'with defined field' do
      before do
        subject << RDF::Statement(nil, RDF::DC.title, 'Kometen kommer')
      end
      
      it 'should not create a context' do
        expect(subject._context).to be nil
      end
      
      it 'should update existing values' do
        expect(subject.title).to eq 'Kometen kommer'
      end
    end

    context 'with undefined field' do
      before do
        subject << RDF::Statement(nil, RDF::DC.description, "Second in Tove Jansson's series of Moomin books")
      end

      it 'should create a context' do
        expect(subject._context).to eq({:description => RDF::DC.description.to_uri.to_s})
      end
      
      it 'should build an accessor' do
        expect(subject.description).to eq "Second in Tove Jansson's series of Moomin books"
      end
    end

    context 'with conflicting field' do
      before do
        subject << RDF::Statement(nil, RDF::DC11.title, "Kometjakten")
      end

      it 'should create a context' do
        expect(subject._context).to eq({:dc11_title => RDF::DC11.title.to_uri.to_s})
      end
      
      it 'should build an accessor' do
        expect(subject.dc11_title).to eq "Kometjakten"
      end
    end
  end
  
  describe '#update_resource' do
    include_context 'with data'

    before do
      # undefined property
      subject.property :description, :predicate => RDF::DC.description
      subject.description = "Second in Tove Jansson's series of Moomin books"

      # conflicting property
      subject.property :title, :predicate => RDF::DC11.title
      subject.dc11_title = "Kometjakten"

      # defined field
      subject << RDF::Statement(nil, RDF::DC.title, 'Kometen kommer')

      # conflicting field
      subject << RDF::Statement(nil, RDF::DC11.title, "Kometjakten")
      
      subject.update_resource
    end
    
    it 'should have updated values' do
      # TODO
    end
  end    

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, "Thing") if Object
    Object.send(:remove_const, "Person") if Object
  end
end