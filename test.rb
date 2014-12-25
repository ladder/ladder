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

  has_one :thumbnail, class_name: 'Image'
  property :thumbnail,  predicate: RDF::FOAF.depiction
end

class Image
  include Ladder::File
end

steve = Person.new(first_name: 'Steve')
i = Image.new(open('http://www.showbizsandbox.com/wp-content/uploads/2011/08/Steve-Jobs.jpg'))
steve.thumbnail = i

steve.save
steve.save

i.save
i.save

#Ladder::File.create :Image
#i = Image.new

#xml = Image.new(data: '<test>some xml data</test>')
#json = Image.new(StringIO.new("{'test' : 'some json data'}"))

binding.pry

=begin
  module ClassMethods

    ##
    # Create a namespaced GridFS module for this class
    def grid
     @grid ||= Mongoid::GridFs.build_namespace_for name
    end

  end

  ##
  # Factory creation method
  def self.create(class_name, &block)
    ns = Mongoid::GridFs.build_namespace_for class_name

    klass = Class.new(ns::File) do
      include ActiveTriples::Identifiable
      include InstanceMethods
      extend ClassMethods

      configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
      @grid = ns

      class_eval(&block) if block_given?
    end

    Object.const_set(class_name, klass)
  end

=end