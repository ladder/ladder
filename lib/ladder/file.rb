require 'mongoid/grid_fs'
require 'active_triples'

module Ladder::File
  extend ActiveSupport::Concern

  include Mongoid::Document
  include ActiveTriples::Identifiable

  included do
    configure base_uri: RDF::URI.new(LADDER_BASE_URI) / name.underscore.pluralize if defined? LADDER_BASE_URI

    store_in collection: "#{ grid.prefix }.files"

    # Define accessor methods for attributes
    define_method(:content_type) { read_attribute(:contentType) }

    grid::File.fields.keys.map(&:to_sym).each do |attr|
      define_method(attr) { read_attribute(attr) }
    end

    around_save :save_file
  end

  attr_accessor :file

  ##
  # Output content of object from stored file or readable input
  def data
    @grid_file ||= self.class.grid.get(id) if persisted?
    return @grid_file.data if @grid_file

    file.rewind if file.respond_to? :rewind
    file.read
  end

  ##
  # Return an empty ActiveTriples resource for serializing related resources
  def update_resource
    resource
  end

  private

    ##
    # Make save behave like Mongoid::Document as much as possible
    def save_file(&block)
      attributes[:content_type] = file.content_type if file.respond_to? :content_type
      @grid_file ? @grid_file.save : !! @grid_file = self.class.grid.put(file, attributes.symbolize_keys)

      persisted? ? run_callbacks(:update) : run_callbacks(:create)
    end

  module ClassMethods
    ##
    # Create a namespaced GridFS module for this class
    def grid
     @grid ||= Mongoid::GridFs.build_namespace_for name
    end
  end

end