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

i = Image.new(file: StringIO.new('testing'))

# KNOWN ISSUE:
# Ladder::File must call #save before the relation is built,
# otherwise the ID asigned to the related object will be outdated
#
# eg. 
#
# GOOD: 
# i.save
# steve.thumbnails << i
# 
# BAD: 
# steve.thumbnails << i
# i.save

binding.pry