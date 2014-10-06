require 'mongoid'
require_relative 'lib/ladder'

LADDER_BASE_URI = 'http://example.org'

Mongoid.load!('mongoid.yml', :development)
Mongoid.logger.level = Logger::DEBUG
Moped.logger.level = Logger::DEBUG

class Thing
  include Ladder::Resource
  configure :type => RDF::OWL.Thing

  property :title, :predicate => RDF::DC.title
  property :date, :predicate => RDF::DC.date
  property :authors, :predicate => RDF::DC.creator, :class_name => 'Person'

  has_and_belongs_to_many :subjects, autosave: true, :class_name => 'Subject'
  property :subjects, :predicate => RDF::DC.subject, :class_name => 'Subject'
  
  embeds_many :identifiers
  property :identifiers, :predicate => RDF::DC.identifier, :class_name => 'Identifier'
end

class Person
  include Ladder::Resource
  configure :type => RDF::FOAF.Person

  property :title, :predicate => RDF::DC.title
  property :things, :predicate => RDF::DC.relation, :class_name => 'Thing', inverse_of: :authors
end

class Subject
  include Ladder::Resource
  configure :type => RDF::SKOS.Concept

  property :title, :predicate => RDF::DC.title
  property :things, :predicate => RDF::DC.relation, :class_name => 'Thing'
end

class Identifier
  include Ladder::Resource
  configure :type => RDF::DC.Standard

  property :title, :predicate => RDF::DC.title

  embedded_in :thing
  property :thing, :predicate => RDF::DC.relation, :class_name => 'Thing'
end

t = Thing.new(title: 'test thing')
p = Person.new(title: 'someone')
s = Subject.new(title: 'important idea')
i = Identifier.new(title: 'unique-ID')

t.authors << p
t.subjects << s
t.identifiers << i

binding.pry