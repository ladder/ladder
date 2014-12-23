require_relative 'lib/ladder'
require 'mongoid'

Mongoid.load!('mongoid.yml', :development)
Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
Mongoid.purge!

LADDER_BASE_URI = 'http://example.org'

class Person
  include Ladder::Resource

  configure type: RDF::FOAF.Person

  property :first_name, predicate: RDF::FOAF.name

  embeds_one :thumbnail, class_name: 'Image'
  property :thumbnail,  predicate: RDF::FOAF.depiction
end

class Image
  include Ladder::File
end

steve = Person.new(first_name: 'Steve')
#steve.thumbnail = Image.new(open('http://www.showbizsandbox.com/wp-content/uploads/2011/08/Steve-Jobs.jpg'))
#steve.save

#xml = Image.new(data: '<test>some xml data</test>')
#json = Image.new(StringIO.new("{'test' : 'some json data'}"))

binding.pry