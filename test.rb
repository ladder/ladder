require_relative 'lib/ladder'
require 'mongoid'
require 'open-uri'

Mongoid.load!('mongoid.yml', :development)
Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
Mongoid.purge!

LADDER_BASE_URI = 'http://example.org'

class Person
  include Ladder::Resource

  configure type: RDF::FOAF.Person

  property :first_name, predicate: RDF::FOAF.name

  belongs_to :thumbnail, class_name: 'Image', :inverse_of => nil, autosave: true
  property :thumbnail,  predicate: RDF::FOAF.depiction
end

class Image
  include Ladder::File
end

steve = Person.new(first_name: 'Steve')
steve.thumbnail = Image.new(file: open('http://www.showbizsandbox.com/wp-content/uploads/2011/08/Steve-Jobs.jpg'))
steve.save

binding.pry