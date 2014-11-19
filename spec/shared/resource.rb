shared_examples 'a Resource' do
  let(:subject) { Thing.new }
  let(:person) { Person.new }

  shared_context 'with data' do
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

  shared_context 'with relations' do
    let(:concept) { Concept.new }
    let(:part)    { Part.new }

    include_context 'with data'
    
    before do
      class Concept
        include Ladder::Resource
      end

      class Part
        include Ladder::Resource
      end

      # many-to-many
      person.class.property :things, :predicate => RDF::DC.relation, :class_name => 'Thing'
      subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'
      subject.people << person

      # one-sided has-many
      subject.class.has_and_belongs_to_many :concepts, inverse_of: nil
      subject.class.property :concepts, :predicate => RDF::DC.subject, :class_name => 'Concept'
      subject.concepts << concept

      # embedded one
      part.class.embedded_in :thing
      part.class.property :thing, :predicate => RDF::DC.relation, :class_name => 'Thing'
      subject.class.embeds_one :part, cascade_callbacks: true
      subject.class.property :part, :predicate => RDF::DC.hasPart, :class_name => 'Part'
      subject.part = part
      subject.save
    end

    after do
      Object.send(:remove_const, 'Concept')
      Object.send(:remove_const, 'Part')
    end

    it 'should have relations' do
      expect(subject.title).to eq 'Comet in Moominland'
      expect(subject.people.to_a).to include person
      expect(subject.concepts.to_a).to include concept
      expect(subject.part).to eq part
    end
    
    it 'should have reverse relations' do
      expect(person.things.to_a).to include subject
      expect(concept.relations).to be_empty
      expect(part.thing).to eq subject
    end
  end

  describe 'LADDER_BASE_URI' do
    it 'should automatically have a base URI' do
      expect(subject.rdf_subject.parent).to eq RDF::URI('http://example.org/things/')
    end
  end

  describe '#property' do
    context 'with non-localized literal' do
      include_context 'with data'

      it 'should return non-localized value' do
        expect(subject.alt).to eq 'Mumintrollet pa kometjakt'
      end
      
      it 'should not be a localized hash' do
        expect(subject.attributes['alt']).to eq 'Mumintrollet pa kometjakt'
      end
      
      it 'should have a valid predicate' do
        expect(subject.class.properties['alt'].predicate).to eq RDF::DC.alternative
      end

      it 'allows resetting of properties' do
        subject.class.property :alt, :predicate => RDF::DC.title
        expect(subject.class.properties['alt'].predicate).to eq RDF::DC.title
      end
    end
    
    context 'with localized literal' do
      include_context 'with data'
      
      it 'should return localized value' do
        expect(subject.title).to eq 'Comet in Moominland'
      end
      
      it 'should return all locales' do
        expect(subject.attributes['title']).to eq({'en' => 'Comet in Moominland'})
      end
      
      it 'should have a valid predicate' do
        expect(subject.class.properties['title'].predicate).to eq RDF::DC.title
      end

      it 'allows resetting of properties' do
        subject.class.property :title, :predicate => RDF::DC.alternative
        expect(subject.class.properties['title'].predicate).to eq RDF::DC.alternative
      end
    end

    context 'with many-to-many' do
      include_context 'with relations'

      it 'should have a relation' do
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(subject.people.to_a).to include person
      end

      it 'should have an inverse relation' do
        expect(person.relations['things'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(person.things.to_a).to include subject
      end

      it 'should have a valid predicate' do
        expect(subject.class.properties['people'].predicate).to eq RDF::DC.creator
      end

      it 'should have a valid inverse predicate' do
        expect(person.class.properties['things'].predicate).to eq RDF::DC.relation
      end
    end

    context 'with one-sided has-many' do
      include_context 'with relations'

      it 'should have a relation' do
        expect(subject.relations['concepts'].relation).to eq (Mongoid::Relations::Referenced::ManyToMany)
        expect(subject.concepts.to_a).to include concept
      end

      it 'should not have an inverse relation' do
        expect(subject.relations['concepts'].inverse_of).to be nil
        expect(concept.relations).to be_empty
      end

      it 'should have a valid predicate' do
        expect(subject.class.properties['concepts'].predicate).to eq RDF::DC.subject
      end

      it 'should not have an inverse predicate' do
        expect(concept.class.properties).to be_empty
      end
    end

    context 'with embeds-many' do
      before do
        subject.class.embeds_many :people
        subject.class.property :people, :predicate => RDF::DC.creator, :class_name => 'Person'

        person.class.embedded_in :thing
        person.class.property :thing, :predicate => RDF::DC.relation, :class_name => 'Thing'

        subject.people << person
      end

      it 'should have a relation' do
        expect(subject.relations['people'].relation).to eq (Mongoid::Relations::Embedded::Many)
        expect(subject.people.to_a).to include person
      end

      it 'should have an inverse relation' do
        expect(person.relations['thing'].relation).to eq (Mongoid::Relations::Embedded::In)
        expect(person.thing).to eq subject
      end

      it 'should have a valid predicate' do
        expect(subject.class.properties['people'].predicate).to eq RDF::DC.creator
      end

      it 'should have a valid inverse predicate' do
        expect(person.class.properties['thing'].predicate).to eq RDF::DC.relation
      end
    end
  end

  describe '#update_resource' do
    context 'without related: true' do
      include_context 'with relations'
      
      before do
        subject.update_resource
      end

      it 'should have a literal object' do
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.title).each_statement do |s|
          expect(s.object.to_s).to eq 'Comet in Moominland'
        end
      end

      it 'should have an embedded object' do
        query = subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.hasPart)
        expect(query.count).to eq 1
        
        query.each_statement do |s|
          expect(s.object).to eq part.rdf_subject
        end
      end

      it 'should have an embedded object relation' do
        query = subject.resource.query(:subject => part.rdf_subject, :predicate => RDF::DC.relation)
        expect(query.count).to eq 1
        expect(query.to_hash).to eq part.resource.statements.to_hash

        query.each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end

      it 'should not have related objects' do
        expect(subject.resource.query(:subject => person.rdf_subject)).to be_empty
        expect(subject.resource.query(:subject => concept.rdf_subject)).to be_empty
      end

      it 'should not have related object relations' do
        expect(person.resource.statements).to be_empty
        expect(concept.resource.statements).to be_empty
      end
    end

    context 'with related: true' do
      include_context 'with relations'
      
      before do
        subject.update_resource(:related => true)
      end

      it 'should have a literal object' do
        subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.title).each_statement do |s|
          expect(s.object.to_s).to eq 'Comet in Moominland'
        end
      end

      it 'should have an embedded object' do
        query = subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.hasPart)
        expect(query.count).to eq 1
        
        query.each_statement do |s|
          expect(s.object).to eq part.rdf_subject
        end
      end

      it 'should have an embedded object relation' do
        query = subject.resource.query(:subject => part.rdf_subject, :predicate => RDF::DC.relation)
        expect(query.count).to eq 1
        expect(query.to_hash).to eq part.resource.statements.to_hash

        query.each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
      end

      it 'should have related objects' do
        # many-to-many
        query_creator = subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.creator)
        expect(query_creator.count).to eq 1

        query_creator.each_statement do |s|
          expect(s.object).to eq person.rdf_subject
        end

        # one-sided has-many
        query_subject = subject.resource.query(:subject => subject.rdf_subject, :predicate => RDF::DC.subject)
        expect(query_subject.count).to eq 1

        query_subject.each_statement do |s|
          expect(s.object).to eq concept.rdf_subject
        end
      end

      it 'should have related object relations' do
        # many-to-many
        query = person.resource.query(:subject => person.rdf_subject, :predicate => RDF::DC.relation)
        expect(query.count).to eq 1
        expect(query.to_hash).to eq person.resource.statements.to_hash

        query.each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
        
        # one-sided has-many
        expect(subject.resource.query(:subject => concept.rdf_subject)).to be_empty
        expect(concept.resource.statements).to be_empty
      end
    end

    context 'with related and then without related' do
      include_context 'with relations'
      
      before do
        subject.update_resource(:related => true)
        subject.update_resource
      end

      it 'should not have related objects' do
        expect(subject.resource.query(:subject => person.rdf_subject)).to be_empty
        expect(subject.resource.query(:subject => concept.rdf_subject)).to be_empty
      end

      it 'should have related object relations' do
        # many-to-many
        query = person.resource.query(:subject => person.rdf_subject, :predicate => RDF::DC.relation)
        expect(query.count).to eq 1
        expect(query.to_hash).to eq person.resource.statements.to_hash

        query.each_statement do |s|
          expect(s.object).to eq subject.rdf_subject
        end
        
        # one-sided has-many
        expect(subject.resource.query(:subject => concept.rdf_subject)).to be_empty
        expect(concept.resource.statements).to be_empty
      end
    end
  end
  
  describe '#as_jsonld' do
    include_context 'with relations'
    
    it 'should output a valid jsonld representation of itself' do
      g = RDF::Graph.new << JSON::LD::API.toRdf(subject.as_jsonld)
      expect(subject.resource.to_hash == g.to_hash).to be true
    end
  end
  
  describe '#rdf_label' do
    include_context 'with relations'

    it 'should return the default label' do
      expect(subject.rdf_label.to_a).to eq ['Comet in Moominland']
    end
  end

end