require 'spec_helper'

describe Ladder::Resource::Dynamic do
  before do
    Mongoid.load!('mongoid.yml', :development)
    Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
    Mongoid.purge!

    LADDER_BASE_URI ||= 'http://example.org'

    class Thing
      include Ladder::Resource::Dynamic
      configure type: RDF::DC.BibliographicResource

      field :alt
      property :alt, predicate: RDF::DC.alternative # non-localized literal
      property :title, predicate: RDF::DC.title     # localized literal
    end
  end

  after do
    Object.send(:remove_const, :LADDER_BASE_URI) if Object
    Object.send(:remove_const, 'Thing') if Object
  end

  context 'with data' do
    let(:subject) { Thing.new }

    before do
      # non-localized literal
      subject.alt = 'Mumintrollet pa kometjakt'

      # localized literal
      subject.title = 'Comet in Moominland'
    end

    it_behaves_like 'a Resource'
    it_behaves_like 'a Dynamic Resource'

    describe '#property' do
      context 'with undefined property' do
        before do
          subject.property :description, predicate: RDF::DC.description
          subject.description = "Second in Tove Jansson's series of Moomin books"
        end

        it 'should create a context' do
          expect(subject._context).to eq(description: RDF::DC.description.to_uri.to_s)
        end

        it 'should build an accessor' do
          expect(subject.description).to eq "Second in Tove Jansson's series of Moomin books"
        end
      end

      context 'with conflicting property' do
        before do
          subject.property :title, predicate: RDF::DC11.title
          subject.dc11_title = 'Kometjakten'
        end

        it 'should create a context' do
          expect(subject._context).to eq(dc11_title: RDF::DC11.title.to_uri.to_s)
        end

        it 'should build an accessor' do
          expect(subject.dc11_title).to eq 'Kometjakten'
        end
      end
    end

    describe '#update_resource' do
      before do
        # undefined property
        subject.property :description, predicate: RDF::DC.description
        subject.description = "Second in Tove Jansson's series of Moomin books"

        # conflicting property
        subject.property :title, predicate: RDF::DC11.title
        subject.dc11_title = 'Kometjakten'

        # defined field
        subject << RDF::Statement(nil, RDF::DC.title, 'Kometen kommer')

        # conflicting property
        subject << RDF::Statement(nil, RDF::DC.alternative, 'Kometjakten')

        # URI value
        subject << RDF::Statement(nil, RDF::DC.identifier, RDF::URI('http://some.uri'))

        # RDF type
        subject << RDF::Statement(nil, RDF.type, RDF::DC.PhysicalResource)

        subject.update_resource
      end

      it 'should have updated values' do
        expect(subject.resource.statements.count).to eq 7
        expect(subject.resource.query(predicate: RDF::DC.description, object: "Second in Tove Jansson's series of Moomin books").count).to eq 1
        expect(subject.resource.query(predicate: RDF::DC11.title, object: 'Kometjakten').count).to eq 1
        expect(subject.resource.query(predicate: RDF::DC.title, object: RDF::Literal.new('Kometen kommer', language: :en)).count).to eq 1
        expect(subject.resource.query(predicate: RDF::DC.alternative, object: 'Kometjakten').count).to eq 1
        expect(subject.resource.query(predicate: RDF::DC.identifier, object: RDF::URI('http://some.uri')).count).to eq 1
      end

      it 'should contain both class and dynamic types' do
        expect(subject.type.count).to eq 2
        expect(subject.type).to include RDF::DC.BibliographicResource
        expect(subject.type).to include RDF::DC.PhysicalResource
      end
    end

    describe '#<<' do
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
          expect(subject._context).to eq(description: RDF::DC.description.to_uri.to_s)
        end

        it 'should build an accessor' do
          expect(subject.description).to eq "Second in Tove Jansson's series of Moomin books"
        end
      end

      context 'with conflicting property' do
        before do
          subject << RDF::Statement(nil, RDF::DC11.title, 'Kometjakten')
        end

        it 'should create a context' do
          expect(subject._context).to eq(dc11_title: RDF::DC11.title.to_uri.to_s)
        end

        it 'should build an accessor' do
          expect(subject.dc11_title).to eq 'Kometjakten'
        end
      end

      context 'with a URI value' do
        before do
          subject << RDF::Statement(nil, RDF::DC.identifier, RDF::URI('http://some.uri'))
        end

        it 'should store the URI as a string' do
          expect(subject.identifier).to eq 'http://some.uri'
        end

        it 'should cast a URI into the resource' do
          subject.update_resource
          query = subject.resource.query(subject: subject.rdf_subject, predicate: RDF::DC.identifier)
          expect(query.first_object).to be_a_kind_of RDF::URI
        end
      end
    end

    describe '#resource_class' do
      before do
        subject.property :description, predicate: RDF::DC.description
      end

      it 'should have modified properties on the instance' do
        expect(subject.resource.class.properties.keys).to include 'description'
      end

      it 'should not modify the global class properties' do
        expect(subject.class.resource_class.properties.keys).to_not include 'description'
        expect(subject.class.resource_class.properties).to eq subject.class.new.class.resource_class.properties
      end
    end
  end

# TODO: complete this test
=begin
  context 'from JSON-LD' do
    let(:subject) { Thing.new_from_graph(RDF::Graph.load './spec/shared/graph.jsonld') }

    before do
      subject.save
    end

    it_behaves_like 'a Resource'
    it_behaves_like 'a Dynamic Resource'
  end
=end
end
