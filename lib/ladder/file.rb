require 'mongoid/grid_fs'
require 'active_triples'

module Ladder::File
  extend ActiveSupport::Concern

  include Mongoid::Document
  include ActiveTriples::Identifiable

  included do
    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI
    
    store_in :collection => "#{ grid.prefix }.files"
    
    after_initialize do
      # If we are loading an existing GridFS file, populate values
      @grid_file = file if file.is_a? self.class.grid::File
      self.id = @grid_file.id if @grid_file
    end
  end

  attr_accessor :file

  delegate :length, :chunkSize, :uploadDate, :md5, :content_type, :contentType, :filename, to: :@grid_file

  ##
  # Make save behave like Mongoid::Document as much as possible
  def save
    raise Mongoid::Errors::InvalidValue.new(IO, NilClass) if file.nil?

    attributes[:content_type] = file.content_type if file.respond_to? :content_type
    @grid_file ? @grid_file.save : !! @grid_file = self.class.grid.put(file, attributes.symbolize_keys)
  end

  ##
  # Output content of object from stored file or readable input
  def data
    return @grid_file.data if @grid_file

    file.rewind if file.respond_to? :rewind
    file.read
  end
  
  ##
  # Return an empty ActiveTriples resource for serializing related resources
  def update_resource
    resource
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