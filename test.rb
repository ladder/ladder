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

  belongs_to :thumbnail, class_name: 'Image', :inverse_of => nil
  property :thumbnail,  predicate: RDF::FOAF.depiction
end

class Image
  include Ladder::File
end

thumb = Image.new(file: open('http://www.showbizsandbox.com/wp-content/uploads/2011/08/Steve-Jobs.jpg'))
thumb.save

steve = Person.new(first_name: 'Steve')
steve.thumbnail = thumb
steve.save

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