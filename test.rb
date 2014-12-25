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
  property :thumbnails,  predicate: RDF::FOAF.depiction, class_name: 'Image'
end

class Image
  include Ladder::File
end

steve = Person.new(first_name: 'Steve')

i = Image.new(file: open('http://www.showbizsandbox.com/wp-content/uploads/2011/08/Steve-Jobs.jpg'))

binding.pry

# steve.save
# i.save
# steve.thumbnails << i