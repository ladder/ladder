require 'mongoid/grid_fs'
require 'active_triples'

module Ladder::File
  extend ActiveSupport::Concern

  include Mongoid::Document
  include ActiveTriples::Identifiable

  included do
    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
    
    store_in :collection => "#{ grid.prefix }.files"
  end

  attr_accessor :file

  def initialize(*args)
    super
    
    # If we are loading an existing GridFS file, populate values
    if file.respond_to?(:data)
      @grid_file = file
      self.id = file.id
    end
  end

  ##
  # Make save behave like Mongoid::Document as much as possible
  def save
    return false if file.nil? or 0 == file.size

    @grid_file ? @grid_file.save : @grid_file = self.class.grid.put(file)
    self.id = @grid_file.id

    true
  end

  ##
  # Output content of object from stored file or readable input
  def data(*opts)
    if @grid_file
      @grid_file.data(*opts)
    else
      file.rewind if file.respond_to? :rewind
      file.read
    end
  end

  module ClassMethods

    ##
    # Create a namespaced GridFS module for this class
    def grid
     @grid ||= Mongoid::GridFs.build_namespace_for name
    end
    
    ##
    # Behave like Mongoid::Document as much as possible
    def find(*args)
      id = args.shift unless args.first.is_a? Hash
      file = id ? grid.get(id) : grid.find(*args)

      self.new(file: file)
    end

  end

end